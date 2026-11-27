#!/bin/sh
# Removes Physics Digest.
#   ./uninstall.sh          remove the app, keep your settings and saved items
#   ./uninstall.sh --purge  also delete settings, database and cache (your ~/Papers folder is never touched)
BIN="$HOME/.local/bin"
"$BIN/physics-digest" --quit >/dev/null 2>&1 || true
pkill -f "$BIN/physics-digest" 2>/dev/null || true
rm -f "$BIN/physics-digest" "$BIN/physics-digest-panel"
rm -f "$HOME/.local/share/icons/physics-digest.svg" "$HOME/.local/share/icons/physics-digest-panel.svg"
rm -f "$HOME/.local/share/applications/physics-digest.desktop" "$HOME/.config/autostart/physics-digest.desktop"
if [ "$1" = "--purge" ]; then
    rm -rf "$HOME/.config/physics-digest" "$HOME/.local/share/physics-digest" "$HOME/.cache/physics-digest"
    echo "Physics Digest and all its data were removed."
else
    echo "Physics Digest was removed. Your settings and saved items are kept in ~/.config/physics-digest"
    echo "and ~/.local/share/physics-digest (run with --purge to delete them too)."
fi
