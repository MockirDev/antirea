#!/bin/sh
# antirea hooks installer — Linux / macOS
# Run from the project root: sh .kilo/skills/antirea/templates/hooks/antirea-hooks-install.sh

set -e

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [ -z "$REPO_ROOT" ]; then
  echo "[antirea] ERROR: Not inside a git repository."
  exit 1
fi

HOOKS_DIR="$REPO_ROOT/.git/hooks"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Copy the barrier content into .git so hooks can access it even if
# the working tree files are deleted.
cp "$SCRIPT_DIR/../agents-inject.md" "$REPO_ROOT/.git/antirea-barrier.md"
echo "[antirea] Barrier content saved to .git/antirea-barrier.md"

# Install hooks
for hook in post-checkout post-merge pre-commit; do
  TARGET="$HOOKS_DIR/$hook"
  if [ -f "$TARGET" ]; then
    # Append to existing hook
    if ! grep -q "antirea" "$TARGET"; then
      echo "" >> "$TARGET"
      echo "# antirea self-heal" >> "$TARGET"
      cat "$SCRIPT_DIR/$hook" >> "$TARGET"
      echo "[antirea] Appended to existing hook: $hook"
    else
      echo "[antirea] Hook already contains antirea: $hook (skipped)"
    fi
  else
    cp "$SCRIPT_DIR/$hook" "$TARGET"
    chmod +x "$TARGET"
    echo "[antirea] Installed hook: $hook"
  fi
done

echo "[antirea] Git hooks installed. Barrier files will self-heal on checkout, merge, and commit."