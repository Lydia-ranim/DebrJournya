#!/usr/bin/env bash
# Runs the app as a phone-sized Linux desktop window (dev preview only).
#
# Works around a GTK 3 crash on recent GNOME: GTK still reads the keys
# "antialiasing", "hinting" and "rgba-order" from the schema
# org.gnome.settings-daemon.plugins.xsettings, which newer GNOME removed
# ("Settings schema ... does not contain a key named 'antialiasing'").
# We compile a private copy of that schema with the keys added and point
# GSETTINGS_SCHEMA_DIR at it for this run only. System settings are untouched.
#
# Usage: tool/run_linux.sh [extra flutter run args]
set -euo pipefail
cd "$(dirname "$0")/.."

dir=.dart_tool/gsettings-fix
mkdir -p "$dir"
cat > "$dir/org.gnome.settings-daemon.plugins.xsettings.gschema.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<schemalist>
  <enum id="dev.debrjournya.FontAntialiasing">
    <value nick="none" value="0"/>
    <value nick="grayscale" value="1"/>
    <value nick="rgba" value="2"/>
  </enum>
  <enum id="dev.debrjournya.FontHinting">
    <value nick="none" value="0"/>
    <value nick="slight" value="1"/>
    <value nick="medium" value="2"/>
    <value nick="full" value="3"/>
  </enum>
  <enum id="dev.debrjournya.FontRgbaOrder">
    <value nick="rgba" value="0"/>
    <value nick="rgb" value="1"/>
    <value nick="bgr" value="2"/>
    <value nick="vrgb" value="3"/>
    <value nick="vbgr" value="4"/>
  </enum>
  <schema id="org.gnome.settings-daemon.plugins.xsettings"
          path="/org/gnome/settings-daemon/plugins/xsettings/">
    <key name="antialiasing" enum="dev.debrjournya.FontAntialiasing">
      <default>'grayscale'</default>
    </key>
    <key name="hinting" enum="dev.debrjournya.FontHinting">
      <default>'slight'</default>
    </key>
    <key name="rgba-order" enum="dev.debrjournya.FontRgbaOrder">
      <default>'rgb'</default>
    </key>
    <key name="disabled-gtk-modules" type="as"><default>[]</default></key>
    <key name="enabled-gtk-modules" type="as"><default>[]</default></key>
    <key name="overrides" type="a{sv}"><default>{}</default></key>
  </schema>
</schemalist>
EOF
glib-compile-schemas "$dir"

# Supabase URL + key (gitignored); without it the app runs on fake data.
defines=()
[ -f env/dev.json ] && defines=(--dart-define-from-file=env/dev.json)

GSETTINGS_SCHEMA_DIR="$PWD/$dir" exec flutter run -d linux "${defines[@]}" "$@"
