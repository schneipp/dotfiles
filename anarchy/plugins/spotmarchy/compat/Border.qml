pragma Singleton

import QtQuick
import Quickshell

// Omarchy describes a border as a spec object with per-edge widths. DMS draws
// a uniform 1px outline, so a spec here is just {width}. top() is the only
// accessor upstream uses — it needs the inset to tighten a corner radius.
Singleton {
    function top(spec): real    { return spec && spec.width !== undefined ? spec.width : 1; }
    function bottom(spec): real { return top(spec); }
    function left(spec): real   { return top(spec); }
    function right(spec): real  { return top(spec); }
}
