#!/usr/bin/env bash
#
# claude-update.sh — Update the Claude Development Framework in a target project
#
# Usage: ./claude-update.sh /path/to/target/project
#
# Framework files (.claude/) are overwritten.
# User data files (registry, decisions, etc.) are preserved if they exist.
#

set -euo pipefail

# --- Configuration ---

PROTECTED_FILES=(
  ".claude/docs/registry.md"
  ".claude/docs/decisions.md"
  ".claude/docs/glossary.md"
  ".claude/docs/request-log.md"
  ".claude/docs/bugs/bugs.md"
  ".claude/settings.local.json"
  ".claude/morpheus/config.json"
)

PROTECTED_DIRS=(
  ".claude/docs/session-notes"
  ".claude/docs/specs"
)

# Files inside protected dirs that ARE framework (always overwrite)
FRAMEWORK_IN_PROTECTED_DIRS=(
  ".claude/docs/specs/template.md"
  ".claude/docs/specs/references/.gitkeep"
)

# --- Validation ---

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${1:-}"

if [ -z "$TARGET_DIR" ]; then
  echo "Usage: $0 /path/to/target/project"
  exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Target directory '$TARGET_DIR' does not exist."
  exit 1
fi

# --- Counters ---

updated=0
preserved=0
initialized=0

# --- Helper ---

is_protected_file() {
  local rel_path="$1"
  for pf in "${PROTECTED_FILES[@]}"; do
    if [ "$rel_path" = "$pf" ]; then
      return 0
    fi
  done
  return 1
}

is_in_protected_dir() {
  local rel_path="$1"
  for pd in "${PROTECTED_DIRS[@]}"; do
    if [[ "$rel_path" == "$pd"/* ]]; then
      return 0
    fi
  done
  return 1
}

is_framework_in_protected_dir() {
  local rel_path="$1"
  for ff in "${FRAMEWORK_IN_PROTECTED_DIRS[@]}"; do
    if [ "$rel_path" = "$ff" ]; then
      return 0
    fi
  done
  return 1
}

# --- Main ---

echo "Claude Framework Update"
echo "======================="
echo "Source: $SOURCE_DIR"
echo "Target: $TARGET_DIR"
echo ""

# Step 1: Copy .claude/ framework files
while IFS= read -r -d '' file; do
  rel_path="${file#"$SOURCE_DIR"/}"

  # Skip non-.claude files (handled separately)
  if [[ "$rel_path" != .claude/* ]]; then
    continue
  fi

  target_file="$TARGET_DIR/$rel_path"
  target_dir="$(dirname "$target_file")"

  # Framework files inside protected dirs: always overwrite
  if is_framework_in_protected_dir "$rel_path"; then
    mkdir -p "$target_dir"
    cp "$file" "$target_file"
    ((updated++))
    continue
  fi

  # Skip user files in protected directories (don't overwrite user specs, session notes)
  if is_in_protected_dir "$rel_path"; then
    if [ -f "$target_file" ]; then
      ((preserved++))
      continue
    fi
    # New file in protected dir — copy it
    mkdir -p "$target_dir"
    cp "$file" "$target_file"
    ((initialized++))
    continue
  fi

  # Protected files: skip if exists, initialize if missing
  if is_protected_file "$rel_path"; then
    if [ -f "$target_file" ]; then
      ((preserved++))
    else
      mkdir -p "$target_dir"
      cp "$file" "$target_file"
      ((initialized++))
    fi
    continue
  fi

  # Everything else: overwrite
  mkdir -p "$target_dir"
  cp "$file" "$target_file"
  ((updated++))

done < <(find "$SOURCE_DIR/.claude" -type f -print0)

# Step 2: Copy root framework files
for root_file in CLAUDE.md .claude-project; do
  if [ -f "$SOURCE_DIR/$root_file" ]; then
    cp "$SOURCE_DIR/$root_file" "$TARGET_DIR/$root_file"
    ((updated++))
  fi
done

# Step 3: Ensure output directories exist
for dir in .emmet .forge; do
  if [ ! -d "$TARGET_DIR/$dir" ]; then
    mkdir -p "$TARGET_DIR/$dir"
    echo "  Created $dir/"
  fi
done

# Step 4: Ensure .claude/morpheus/ exists
if [ ! -d "$TARGET_DIR/.claude/morpheus" ]; then
  mkdir -p "$TARGET_DIR/.claude/morpheus"
  echo "  Created .claude/morpheus/"
fi

# --- Report ---

echo ""
echo "Done."
echo "  Updated:     $updated files"
echo "  Preserved:   $preserved files (user data)"
echo "  Initialized: $initialized files (new templates)"
