// Time-synced lyrics for the Spotify panel. Pure helpers, kept out of
// BarWidget.qml for the same reason Model.js is: the QML stays declarative and
// these stay trivially testable under node (see test/lyrics-test.js).
//
// Spotify publishes no lyrics over MPRIS and none through any public API, so
// they come from LRCLIB — an open, keyless database of LRC files, keyed on
// track, artist, album and duration. The player supplies the clock; LRCLIB
// supplies the words; `activeIndex` is the whole of the synchronisation.

// The API answers with whatever some contributor uploaded, so everything from
// `parseResponse` down treats the body as hostile: bounded line count, bounded
// line length, control characters stripped, and the panel renders it as
// Text.PlainText so no line can arrive as markup.

var MAX_LINES = 2000
var MAX_LINE_CHARS = 300

// ------------------------------------------------------------------- query

// What LRCLIB needs to identify a track, or null when the player has not
// published enough to ask with. Album and duration are optional — they only
// sharpen the exact-match lookup, which falls back to search regardless.
function queryFor(title, artist, album, duration) {
  var track = collapse(String(title || ""))
  var by = collapse(String(artist || ""))
  if (!track || !by) return null

  var seconds = Math.round(Number(duration) || 0)
  return {
    track: track,
    artist: by,
    album: collapse(String(album || "")),
    duration: seconds > 0 ? String(seconds) : "",
    // A second-chance title for the fuzzy search: Spotify ships remaster and
    // edition suffixes that LRCLIB's copy of the same song does not carry.
    alt: simplifyTitle(track)
  }
}

// The key the disk cache is named after, and the identity the panel compares
// against so a reply that lands after the track moved on is discarded.
function queryKey(query) {
  if (!query) return ""
  // Joined on a unit separator, which `sanitize` has already removed from
  // every field, so no combination of values can produce two equal keys.
  return [query.track, query.artist, query.album, query.duration].join("\u001f")
}

// "Song - 2011 Remaster" and "Song (Deluxe Edition)" are the same song as
// "Song" as far as lyrics go. Only edition-shaped suffixes are cut: a dash in
// "Sunday Bloody Sunday - Live" is a suffix, one in "Marie - A Song" is not,
// so the tail has to name an edition to be dropped.
var editionWords = /\b(remaster(ed)?|re-?recorded|version|edit|mix|remix|mono|stereo|deluxe|expanded|anniversary|bonus|radio|single|album|instrumental|acoustic|unplugged|session|live|demo|edition|take)\b/i

function simplifyTitle(title) {
  var out = String(title || "")

  // Trailing bracketed editions, innermost last: "A (Live) (Remastered)".
  for (var i = 0; i < 3; i++) {
    var bracket = /\s*[\(\[]([^\(\)\[\]]*)[\)\]]\s*$/.exec(out)
    if (!bracket || !editionWords.test(bracket[1])) break
    out = out.slice(0, bracket.index)
  }

  // A dash suffix, which is how Spotify writes most of them.
  var dash = /\s+-\s+([^-]*)$/.exec(out)
  if (dash && editionWords.test(dash[1])) out = out.slice(0, dash.index)

  out = collapse(out)
  return out || collapse(title)
}

// ------------------------------------------------------------------- fetch
//
// One shell script, with every field passed as a positional argument and
// url-encoded by curl itself, so a track called `"; rm -rf ~` is a track name
// and never anything else. The reply is bounded on the wire and again on disk,
// and the whole answer — including "there are none" — is cached, because a
// track played twice should not be two requests to a volunteer-run service.
function fetchScript() {
  return [
    'set -eu',
    '',
    '# An LRC file is a few kilobytes; a search page of them, a few dozen.',
    'max=1000000',
    'ua="spotmarchy-lyrics (Omarchy bar widget)"',
    '',
    'tmp=$(mktemp) || exit 1',
    'trap \'rm -f "$tmp"\' EXIT',
    '',
    'cache="${XDG_CACHE_HOME:-$HOME/.cache}/spotmarchy/lyrics"',
    'mkdir -p "$cache" || exit 1',
    'chmod 700 "$cache" 2>/dev/null || :',
    '',
    '# Named for the query, so the cache is per-track and a new track is a new',
    '# path rather than an overwrite of the last one.',
    'key=$(printf \'%s\\n%s\\n%s\\n%s\\n\' "$1" "$2" "$3" "$4" | sha256sum | cut -c1-32) || exit 1',
    'hit="$cache/$key.json"',
    '',
    'if [ -f "$hit" ]; then',
    '  # A hit is kept indefinitely, but a recorded miss is re-asked after a',
    '  # fortnight: LRCLIB grows, and today\'s missing song is next month\'s.',
    '  if head -n 1 "$hit" | grep -q "^KIND NONE$"; then',
    '    [ -n "$(find "$hit" -mtime +13 2>/dev/null)" ] || { cat "$hit"; exit 0; }',
    '  else',
    '    cat "$hit"',
    '    exit 0',
    '  fi',
    'fi',
    '',
    '# No redirects: lrclib.net is the host this was written against, and a',
    '# redirect would move the request to one it was not.',
    'api() {',
    '  curl -sfG --proto "=https" --max-redirs 0 --max-filesize "$max" \\',
    '       --max-time 8 -A "$ua" -H "Accept: application/json" -o "$tmp" "$@"',
    '}',
    '',
    'kind=NONE',
    '',
    '# The exact lookup first. It matches on duration too, so when it answers',
    '# the LRC is certainly for the recording that is actually playing.',
    'if [ -n "$4" ] && api --data-urlencode "track_name=$1" \\',
    '                     --data-urlencode "artist_name=$2" \\',
    '                     --data-urlencode "album_name=$3" \\',
    '                     --data-urlencode "duration=$4" \\',
    '                     -- "https://lrclib.net/api/get"; then',
    '  kind=GET',
    'elif api --data-urlencode "track_name=$1" \\',
    '         --data-urlencode "artist_name=$2" \\',
    '         -- "https://lrclib.net/api/search"; then',
    '  kind=SEARCH',
    'elif [ "$5" != "$1" ] && api --data-urlencode "track_name=$5" \\',
    '                             --data-urlencode "artist_name=$2" \\',
    '                             -- "https://lrclib.net/api/search"; then',
    '  kind=SEARCH',
    'fi',
    '',
    'if [ "$kind" = NONE ]; then',
    '  printf "KIND NONE\\n" > "$hit.new"',
    'else',
    '  # --max-filesize acts only on a declared Content-Length, so the size that',
    '  # decides is the one on disk.',
    '  size=$(wc -c < "$tmp") || exit 1',
    '  [ "$size" -gt 0 ] && [ "$size" -le "$max" ] || exit 1',
    '  { printf "KIND %s\\n" "$kind"; cat "$tmp"; } > "$hit.new" || exit 1',
    'fi',
    '',
    'mv -f "$hit.new" "$hit" || exit 1',
    '',
    '# Keep a few hundred. Every name here is hex, so the listing is safe to',
    '# read line by line.',
    'ls -1t "$cache"/*.json 2>/dev/null | tail -n +257 | while IFS= read -r stale; do',
    '  rm -f -- "$stale"',
    'done',
    '',
    'cat "$hit"'
  ].join('\n')
}

// ------------------------------------------------------------------- parse

// The script's stdout turned into what the panel shows:
//   { kind: "synced" | "plain" | "instrumental" | "none", lines: [...], record }
// where a line is { time, text } and `time` is -1 for unsynced lyrics.
function parseResponse(text, wantedDuration) {
  var body = String(text || "")
  var newline = body.indexOf("\n")
  if (newline === -1) return none()

  var header = body.slice(0, newline).trim()
  if (header === "KIND NONE") return none()
  if (header !== "KIND GET" && header !== "KIND SEARCH") return none()

  var payload
  try {
    payload = JSON.parse(body.slice(newline + 1))
  } catch (e) {
    return none()
  }

  var record = Array.isArray(payload) ? pickRecord(payload, wantedDuration) : payload
  if (!record || typeof record !== "object") return none()

  var result = fromRecord(record)
  result.record = {
    name: collapse(String(record.trackName || record.name || "")),
    artist: collapse(String(record.artistName || "")),
    duration: Number(record.duration) || 0
  }
  return result
}

// Search returns every recording of a title. Prefer one with real timings,
// then the one whose length is closest to what is actually playing — that is
// what separates the album cut from the single edit and the live version.
function pickRecord(list, wantedDuration) {
  var wanted = Number(wantedDuration) || 0
  var best = null
  var bestScore = -Infinity

  for (var i = 0; i < list.length && i < 50; i++) {
    var item = list[i]
    if (!item || typeof item !== "object") continue

    var synced = typeof item.syncedLyrics === "string" && item.syncedLyrics.length > 0
    var plain = typeof item.plainLyrics === "string" && item.plainLyrics.length > 0
    if (!synced && !plain && item.instrumental !== true) continue

    var score = synced ? 1000 : item.instrumental === true ? 200 : 500
    if (wanted > 0) {
      var drift = Math.abs((Number(item.duration) || 0) - wanted)
      // Two seconds is LRCLIB's own tolerance for an exact match; past that,
      // every further second is a point of doubt.
      score -= drift <= 2 ? 0 : Math.min(400, (drift - 2) * 4)
    }

    if (score > bestScore) {
      bestScore = score
      best = item
    }
  }

  return best
}

function fromRecord(record) {
  if (record.instrumental === true) return { kind: "instrumental", lines: [] }

  var synced = parseLrc(record.syncedLyrics)
  if (synced.length) return { kind: "synced", lines: synced }

  var plain = parsePlain(record.plainLyrics)
  if (plain.length) return { kind: "plain", lines: plain }

  return none()
}

function none() {
  return { kind: "none", lines: [] }
}

// LRC: one or more `[mm:ss.xx]` stamps, then the line. Metadata tags are
// skipped except `[offset:]`, which players are expected to honour.
function parseLrc(text) {
  var source = String(text || "")
  if (!source) return []

  var raw = source.split("\n")
  var out = []
  var offset = 0

  for (var i = 0; i < raw.length && out.length < MAX_LINES; i++) {
    var line = raw[i]

    var offsetTag = /^\s*\[offset:\s*([+-]?\d+)\s*\]\s*$/i.exec(line)
    if (offsetTag) {
      // Bounded, because the tag is as user-supplied as the lyrics are and a
      // wild value would park every line outside the song.
      offset = clamp(Number(offsetTag[1]) / 1000, -30, 30)
      continue
    }

    var rest = line
    var stamps = []
    var stamp

    while ((stamp = /^\s*\[(\d{1,3}):([0-5]?\d)(?:[.:](\d{1,3}))?\]/.exec(rest))) {
      var fraction = stamp[3] ? Number(stamp[3]) / Math.pow(10, stamp[3].length) : 0
      stamps.push(Number(stamp[1]) * 60 + Number(stamp[2]) + fraction)
      rest = rest.slice(stamp[0].length)
    }

    if (!stamps.length) continue

    var content = sanitize(rest)
    for (var s = 0; s < stamps.length && out.length < MAX_LINES; s++) {
      out.push({ time: stamps[s], text: content })
    }
  }

  if (!out.length) return []

  // A positive offset means the words are wanted sooner, so it comes off the
  // timings rather than being added to them.
  for (var j = 0; j < out.length; j++) {
    out[j].time = Math.max(0, out[j].time - offset)
  }

  out.sort(function(a, b) { return a.time - b.time })
  return out
}

// Unsynced lyrics still beat none: they scroll by hand instead of by clock.
function parsePlain(text) {
  var raw = String(text || "").split("\n")
  var out = []

  for (var i = 0; i < raw.length && out.length < MAX_LINES; i++) {
    out.push({ time: -1, text: sanitize(raw[i]) })
  }

  while (out.length && out[out.length - 1].text === "") out.pop()
  return out.length ? out : []
}

// ---------------------------------------------------------------- playback

// The line the song is on: the last one whose stamp has passed. -1 before the
// first line, which is the intro and should highlight nothing.
function activeIndex(lines, position) {
  if (!lines || !lines.length) return -1
  if (lines[0].time < 0) return -1

  var at = Number(position)
  if (!isFinite(at) || at < lines[0].time) return -1

  var low = 0
  var high = lines.length - 1
  var found = -1

  while (low <= high) {
    var mid = (low + high) >> 1
    if (lines[mid].time <= at) {
      found = mid
      low = mid + 1
    } else {
      high = mid - 1
    }
  }

  return found
}

// How long until the next line, for the countdown during a long instrumental
// break. Negative means there is no next line.
function timeToNext(lines, index, position) {
  if (!lines || index < -1 || index + 1 >= lines.length) return -1
  var next = lines[index + 1]
  if (!next || next.time < 0) return -1
  return Math.max(0, next.time - (Number(position) || 0))
}

// What the panel says when there is nothing to show yet.
function statusText(state, kind) {
  if (state === "off") return ""
  if (state === "idle") return "Nothing playing"
  if (state === "searching") return "Looking for lyrics…"
  if (state === "failed") return "Could not reach LRCLIB"
  if (kind === "instrumental") return "Instrumental"
  return "No lyrics for this track"
}

// ----------------------------------------------------------------- hygiene

// Lyrics are third-party text on their way into a QML Text item. Control
// characters are stripped so nothing can rewrite the line, and the length is
// capped so one pathological line cannot stall the layout.
function sanitize(value) {
  var text = String(value === undefined || value === null ? "" : value)
  var out = ""

  for (var i = 0; i < text.length && out.length < MAX_LINE_CHARS; i++) {
    var code = text.charCodeAt(i)
    if (code < 0x20 || code === 0x7f) {
      out += " "
      continue
    }
    // Bidi overrides and line/paragraph separators reorder or break a line
    // into something other than what it reads as.
    if (code === 0x2028 || code === 0x2029) continue
    if (code >= 0x202a && code <= 0x202e) continue
    if (code >= 0x2066 && code <= 0x2069) continue
    out += text.charAt(i)
  }

  return out.replace(/\s+/g, " ").trim()
}

function collapse(value) {
  return sanitize(value)
}

function clamp(value, low, high) {
  var number = Number(value)
  if (!isFinite(number)) return low
  return number < low ? low : number > high ? high : number
}

// Nothing here touches Qt, so the whole file also loads under node and the
// tests in test/lyrics-test.js exercise it directly. QML's .js import ignores
// this block.
if (typeof module !== "undefined") {
  module.exports = {
    queryFor: queryFor,
    queryKey: queryKey,
    simplifyTitle: simplifyTitle,
    fetchScript: fetchScript,
    parseResponse: parseResponse,
    pickRecord: pickRecord,
    parseLrc: parseLrc,
    parsePlain: parsePlain,
    activeIndex: activeIndex,
    timeToNext: timeToNext,
    statusText: statusText,
    sanitize: sanitize
  }
}
