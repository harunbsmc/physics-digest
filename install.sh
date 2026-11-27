#!/bin/sh
# Installs Physics Digest for the current user.
#   ./install.sh            install (or update) and start the background service
#   SKIP_DEPS=1 ./install.sh  skip installing system packages
set -e
cd "$(dirname "$0")"

BIN="$HOME/.local/bin"
ICONS="$HOME/.local/share/icons"
APPS="$HOME/.local/share/applications"
AUTO="$HOME/.config/autostart"
CONF="$HOME/.config/physics-digest"

if [ -z "$SKIP_DEPS" ]; then
    if command -v apt >/dev/null 2>&1; then
        echo "Installing dependencies (sudo)..."
        sudo apt install -y python3-gi gir1.2-gtk-3.0 librsvg2-common python3-matplotlib python3-numpy libnotify-bin
    else
        echo "Not a Debian/Ubuntu system: please install PyGObject (GTK 3), librsvg, matplotlib and numpy yourself."
    fi
fi

echo "Installing Physics Digest..."
mkdir -p "$BIN" "$ICONS" "$APPS" "$AUTO" "$CONF"
"$BIN/physics-digest" --quit >/dev/null 2>&1 || true
install -m 755 physics-digest "$BIN/physics-digest"
install -m 755 physics-digest-panel "$BIN/physics-digest-panel"
install -m 644 icons/physics-digest.svg icons/physics-digest-panel.svg "$ICONS/"

if [ ! -f "$CONF/config.json" ]; then
    cp config.example.json "$CONF/config.json"
    NEW_CONFIG=1
fi

cat > "$APPS/physics-digest.desktop" <<DESK
[Desktop Entry]
Type=Application
Name=Physics Digest
Comment=Claude-curated arXiv papers and physics news
Exec=$BIN/physics-digest
Icon=$ICONS/physics-digest.svg
Categories=Education;Science;
DESK
cat > "$AUTO/physics-digest.desktop" <<DESK
[Desktop Entry]
Type=Application
Name=Physics Digest (background)
Comment=Checks arXiv and news feeds and sends notifications
Exec=$BIN/physics-digest --daemon
X-GNOME-Autostart-enabled=true
DESK

setsid -f "$BIN/physics-digest" --daemon >/dev/null 2>&1 || true

echo
echo "Done. Physics Digest now runs in the background and starts at every login."
echo "Open the window from your app menu (\"Physics Digest\") or run: physics-digest"
if [ -n "$NEW_CONFIG" ]; then
    echo
    echo "Next step: edit $CONF/config.json"
    echo "  - write your profile (Claude uses it to pick papers for you)"
    echo "  - choose your arXiv categories and keywords"
fi
command -v claude >/dev/null 2>&1 || {
    echo
    echo "Tip: install Claude Code (https://claude.com/claude-code) and sign in to get daily picks,"
    echo "     explanations and summaries. Without it, Physics Digest works with keyword matching only."
}
