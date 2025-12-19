#!/bin/bash

# PulseAudio Remote Audio Setup for macOS
# This script sets up PulseAudio to receive audio from remote Linux machines via SSH tunnel

set -e

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║     PulseAudio Remote Audio Setup for macOS                ║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
  echo -e "${RED}Error: This script is intended for macOS only.${NC}"
  exit 1
fi

# Step 1: Check/Install Homebrew
echo -e "${BOLD}[1/5] Checking Homebrew...${NC}"
if ! command -v brew &>/dev/null; then
  echo -e "${YELLOW}Homebrew not found. Installing...${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for Apple Silicon
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  echo -e "${GREEN}✓ Homebrew is installed${NC}"
fi

# Determine Homebrew prefix
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

# Step 2: Check/Install PulseAudio
echo ""
echo -e "${BOLD}[2/5] Checking PulseAudio...${NC}"
if ! command -v pulseaudio &>/dev/null; then
  echo -e "${YELLOW}PulseAudio not found. Installing via Homebrew...${NC}"
  brew install pulseaudio
else
  echo -e "${GREEN}✓ PulseAudio is installed${NC}"
fi

PA_PATH="${BREW_PREFIX}/bin/pulseaudio"
PACTL_PATH="${BREW_PREFIX}/bin/pactl"

# Step 3: Start PulseAudio temporarily to detect sinks
echo ""
echo -e "${BOLD}[3/5] Detecting audio devices...${NC}"

# Kill any existing PulseAudio
"${PA_PATH}" --kill 2>/dev/null || true
sleep 1

# Start PulseAudio in background
"${PA_PATH}" --start --exit-idle-time=-1 2>/dev/null || true
sleep 3

# Get list of sinks
echo ""
echo -e "${BOLD}Available audio outputs:${NC}"
echo ""

# Create arrays for sink names and descriptions
declare -a SINK_NAMES
declare -a SINK_DESCS

i=1
while IFS= read -r line; do
  if [[ "$line" =~ ^[[:space:]]*Name:\ (.+)$ ]]; then
    current_name="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^[[:space:]]*Description:\ (.+)$ ]]; then
    current_desc="${BASH_REMATCH[1]}"
    SINK_NAMES+=("$current_name")
    SINK_DESCS+=("$current_desc")
    echo -e "  ${BOLD}$i)${NC} $current_desc"
    echo -e "     ${YELLOW}($current_name)${NC}"
    ((i++))
  fi
done < <("${PACTL_PATH}" list sinks 2>/dev/null)

if [[ ${#SINK_NAMES[@]} -eq 0 ]]; then
  echo -e "${RED}Error: No audio sinks found. Make sure PulseAudio can access your audio devices.${NC}"
  exit 1
fi

echo ""
echo -e "${BOLD}[4/5] Select default audio output:${NC}"
echo -n "Enter number (1-${#SINK_NAMES[@]}): "
read -r selection

# Validate selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [[ "$selection" -lt 1 ]] || [[ "$selection" -gt ${#SINK_NAMES[@]} ]]; then
  echo -e "${RED}Invalid selection. Exiting.${NC}"
  exit 1
fi

SELECTED_SINK="${SINK_NAMES[$((selection - 1))]}"
SELECTED_DESC="${SINK_DESCS[$((selection - 1))]}"

echo -e "${GREEN}✓ Selected: $SELECTED_DESC${NC}"

# Get list of sources (microphones)
echo ""
echo -e "${BOLD}Available audio inputs (microphones):${NC}"
echo ""

declare -a SOURCE_NAMES
declare -a SOURCE_DESCS

i=1
while IFS= read -r line; do
  if [[ "$line" =~ ^[[:space:]]*Name:\ (.+)$ ]]; then
    current_name="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^[[:space:]]*Description:\ (.+)$ ]]; then
    current_desc="${BASH_REMATCH[1]}"
    # Skip monitor sources (they capture output, not mic input)
    if [[ ! "$current_name" =~ \.monitor$ ]]; then
      SOURCE_NAMES+=("$current_name")
      SOURCE_DESCS+=("$current_desc")
      echo -e "  ${BOLD}$i)${NC} $current_desc"
      echo -e "     ${YELLOW}($current_name)${NC}"
      ((i++))
    fi
  fi
done < <("${PACTL_PATH}" list sources 2>/dev/null)

SELECTED_SOURCE=""
SELECTED_SOURCE_DESC=""

if [[ ${#SOURCE_NAMES[@]} -eq 0 ]]; then
  echo -e "${YELLOW}No microphone sources found. Skipping mic setup.${NC}"
else
  echo ""
  echo -e "${BOLD}Select default audio input (or 0 to skip):${NC}"
  echo -n "Enter number (0-${#SOURCE_NAMES[@]}): "
  read -r mic_selection

  if [[ "$mic_selection" =~ ^[0-9]+$ ]] && [[ "$mic_selection" -ge 1 ]] && [[ "$mic_selection" -le ${#SOURCE_NAMES[@]} ]]; then
    SELECTED_SOURCE="${SOURCE_NAMES[$((mic_selection - 1))]}"
    SELECTED_SOURCE_DESC="${SOURCE_DESCS[$((mic_selection - 1))]}"
    echo -e "${GREEN}✓ Selected: $SELECTED_SOURCE_DESC${NC}"
  else
    echo -e "${YELLOW}Skipping microphone setup${NC}"
  fi
fi

# Stop PulseAudio for now
"${PA_PATH}" --kill 2>/dev/null || true

# Step 5: Create wrapper script and LaunchAgent
echo ""
echo -e "${BOLD}[5/5] Creating startup configuration...${NC}"

# Create config directory
mkdir -p "$HOME/.config/pulse"

# Create wrapper script with full paths
cat >"$HOME/.config/pulse/start-pulseaudio-tcp.sh" <<EOF
#!/bin/bash
export PATH="${BREW_PREFIX}/bin:\$PATH"

# Kill any existing instance
"${PA_PATH}" --kill 2>/dev/null || true
sleep 1

# Start PulseAudio
"${PA_PATH}" --exit-idle-time=-1 --daemonize=false &
PA_PID=\$!
sleep 3

# Load TCP module and set default sink
"${PACTL_PATH}" load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
"${PACTL_PATH}" set-default-sink "${SELECTED_SINK}"
$(if [[ -n "$SELECTED_SOURCE" ]]; then echo "\"${PACTL_PATH}\" set-default-source \"${SELECTED_SOURCE}\""; fi)

# Wait for PulseAudio to exit
wait \$PA_PID
EOF

chmod +x "$HOME/.config/pulse/start-pulseaudio-tcp.sh"
echo -e "${GREEN}✓ Created wrapper script${NC}"

# Create LaunchAgent
PLIST_PATH="$HOME/Library/LaunchAgents/org.pulseaudio.remote.plist"
mkdir -p "$HOME/Library/LaunchAgents"

# Unload if already loaded
launchctl unload "$PLIST_PATH" 2>/dev/null || true

cat >"$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.pulseaudio.remote</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>${HOME}/.config/pulse/start-pulseaudio-tcp.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/pulseaudio.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/pulseaudio.err</string>
</dict>
</plist>
EOF

echo -e "${GREEN}✓ Created LaunchAgent${NC}"

# Load the LaunchAgent
launchctl load "$PLIST_PATH"
echo -e "${GREEN}✓ LaunchAgent loaded${NC}"

# Wait and verify
sleep 5

echo ""
echo -e "${BOLD}Verifying installation...${NC}"

if "${PA_PATH}" --check 2>/dev/null; then
  echo -e "${GREEN}✓ PulseAudio is running${NC}"
else
  echo -e "${RED}✗ PulseAudio is not running${NC}"
  echo -e "${YELLOW}  Check /tmp/pulseaudio.err for errors${NC}"
fi

# Check if TCP module is loaded
if "${PACTL_PATH}" list modules 2>/dev/null | grep -q "module-native-protocol-tcp"; then
  echo -e "${GREEN}✓ TCP module loaded - listening on port 4713${NC}"
else
  echo -e "${RED}✗ TCP module not loaded${NC}"
fi

# Check if port is listening
if lsof -i :4713 >/dev/null 2>&1; then
  echo -e "${GREEN}✓ Port 4713 is listening${NC}"
else
  echo -e "${RED}✗ Port 4713 is not listening${NC}"
fi

# Final summary
echo ""
echo -e "${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║                    Setup Complete!                         ║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Client-side (this Mac):${NC}"
echo -e "  • PulseAudio installed at: ${PA_PATH}"
echo -e "  • Default speaker: ${SELECTED_DESC}"
if [[ -n "$SELECTED_SOURCE" ]]; then
  echo -e "  • Default microphone: ${SELECTED_SOURCE_DESC}"
fi
echo -e "  • LaunchAgent: auto-starts on login"
echo -e "  • TCP listener: port 4713"
echo ""
echo -e "${BOLD}════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Server-side setup (Linux machine):${NC}"
echo -e "${BOLD}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}1. Add SSH tunnel to ~/.ssh/config on this Mac:${NC}"
echo ""
echo "   Host your-server"
echo "       HostName YOUR_SERVER_IP"
echo "       User YOUR_USERNAME"
echo "       RemoteForward 24713 localhost:4713"
echo ""
echo -e "${YELLOW}2. On your Linux server, add to ~/.xsession or ~/.bashrc:${NC}"
echo ""
echo "   export PULSE_SERVER=tcp:localhost:24713"
echo ""
echo -e "${YELLOW}3. Test audio (after connecting via SSH with tunnel):${NC}"
echo ""
echo "   # Test speakers"
echo "   PULSE_SERVER=tcp:localhost:24713 paplay /usr/share/sounds/freedesktop/stereo/bell.ogg"
echo ""
echo "   # Test microphone (record 3 seconds, then playback)"
echo "   PULSE_SERVER=tcp:localhost:24713 parecord --channels=1 test.wav & sleep 3; kill \$!"
echo "   PULSE_SERVER=tcp:localhost:24713 paplay test.wav"
echo ""
echo -e "${BOLD}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Happy remote audio! 🎵${NC}"
echo ""
