#!/usr/bin/env bash
#
# framework-update.sh — Update the Claude Development Framework in a target project
#
# Usage: ./framework-update.sh /path/to/target/project [--dry-run]
#
# Framework files (.claude/) are overwritten.
# User data files (registry, decisions, etc.) are preserved if they exist.
# A backup of overwritten files is created before any changes.
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

# --- Parse arguments ---

DRY_RUN=false
TARGET_DIR=""

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      ;;
    -*)
      echo "Error: Unknown option '$arg'"
      echo "Usage: $0 /path/to/target/project [--dry-run]"
      exit 1
      ;;
    *)
      if [ -z "$TARGET_DIR" ]; then
        TARGET_DIR="$arg"
      else
        echo "Error: Multiple target directories specified."
        echo "Usage: $0 /path/to/target/project [--dry-run]"
        exit 1
      fi
      ;;
  esac
done

# --- Validation ---

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "$TARGET_DIR" ]; then
  echo "Usage: $0 /path/to/target/project [--dry-run]"
  exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Target directory '$TARGET_DIR' does not exist."
  exit 1
fi

# Resolve to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# Prevent updating self
if [ "$SOURCE_DIR" = "$TARGET_DIR" ]; then
  echo "Error: Source and target are the same directory."
  exit 1
fi

# --- Counters ---

updated=0
preserved=0
initialized=0
backed_up=0

# --- Backup setup ---

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$TARGET_DIR/.framework-backup-$TIMESTAMP"

# --- Helpers ---

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

backup_file() {
  local rel_path="$1"
  local target_file="$TARGET_DIR/$rel_path"
  if [ -f "$target_file" ]; then
    local backup_file="$BACKUP_DIR/$rel_path"
    local backup_dir
    backup_dir="$(dirname "$backup_file")"
    if [ "$DRY_RUN" = false ]; then
      mkdir -p "$backup_dir"
      cp "$target_file" "$backup_file"
    fi
    ((backed_up++))
  fi
}

# --- Git uncommitted changes check ---

check_git_status() {
  if [ ! -d "$TARGET_DIR/.git" ]; then
    return
  fi

  local dirty_files
  dirty_files="$(cd "$TARGET_DIR" && git status --porcelain -- .claude/ CLAUDE.md 2>/dev/null || true)"

  if [ -n "$dirty_files" ]; then
    echo ""
    echo "WARNING: Target project has uncommitted changes in framework files:"
    echo "$dirty_files" | head -20
    local count
    count="$(echo "$dirty_files" | wc -l)"
    if [ "$count" -gt 20 ]; then
      echo "  ... and $((count - 20)) more"
    fi
    echo ""
    if [ "$DRY_RUN" = true ]; then
      echo "(Dry run — no changes will be made)"
      return
    fi
    read -rp "Continue anyway? Uncommitted changes will be backed up. [y/N] " answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
      echo "Aborted."
      exit 0
    fi
  fi
}

# --- CLAUDE.md diff check ---

check_claude_md() {
  local source_file="$SOURCE_DIR/CLAUDE.md"
  local target_file="$TARGET_DIR/CLAUDE.md"

  if [ ! -f "$source_file" ] || [ ! -f "$target_file" ]; then
    return
  fi

  if ! diff -q "$source_file" "$target_file" > /dev/null 2>&1; then
    echo ""
    echo "WARNING: CLAUDE.md in the target project differs from the framework version."
    echo "  This may indicate project-specific customizations."
    echo ""
    if [ "$DRY_RUN" = true ]; then
      echo "  (Dry run — would backup to .framework-backup-$TIMESTAMP/CLAUDE.md)"
      return
    fi
    echo "  Options:"
    echo "    [o] Overwrite (backup current → update to new)"
    echo "    [k] Keep current (skip CLAUDE.md update)"
    echo ""
    read -rp "  Choice [o/k]: " choice
    case "$choice" in
      [Oo])
        CLAUDE_MD_ACTION="overwrite"
        ;;
      *)
        CLAUDE_MD_ACTION="keep"
        ;;
    esac
  fi
}

CLAUDE_MD_ACTION="overwrite"  # default

# --- Dry-run scan ---

scan_changes() {
  local mode="$1"  # "count" or "print"
  local scan_updated=0
  local scan_preserved=0
  local scan_initialized=0

  while IFS= read -r -d '' file; do
    local rel_path="${file#"$SOURCE_DIR"/}"

    if [[ "$rel_path" != .claude/* ]]; then
      continue
    fi

    local target_file="$TARGET_DIR/$rel_path"

    if is_framework_in_protected_dir "$rel_path"; then
      ((scan_updated++))
      [ "$mode" = "print" ] && echo "  OVERWRITE  $rel_path"
      continue
    fi

    if is_in_protected_dir "$rel_path"; then
      if [ -f "$target_file" ]; then
        ((scan_preserved++))
        [ "$mode" = "print" ] && echo "  PRESERVE   $rel_path"
      else
        ((scan_initialized++))
        [ "$mode" = "print" ] && echo "  INIT       $rel_path"
      fi
      continue
    fi

    if is_protected_file "$rel_path"; then
      if [ -f "$target_file" ]; then
        ((scan_preserved++))
        [ "$mode" = "print" ] && echo "  PRESERVE   $rel_path"
      else
        ((scan_initialized++))
        [ "$mode" = "print" ] && echo "  INIT       $rel_path"
      fi
      continue
    fi

    if [ -f "$target_file" ]; then
      ((scan_updated++))
      [ "$mode" = "print" ] && echo "  OVERWRITE  $rel_path"
    else
      ((scan_initialized++))
      [ "$mode" = "print" ] && echo "  INIT       $rel_path"
    fi

  done < <(find "$SOURCE_DIR/.claude" -type f -print0)

  # Root files
  for root_file in CLAUDE.md .claude-project; do
    if [ -f "$SOURCE_DIR/$root_file" ]; then
      if [ "$root_file" = "CLAUDE.md" ] && [ "$CLAUDE_MD_ACTION" = "keep" ]; then
        ((scan_preserved++))
        [ "$mode" = "print" ] && echo "  KEEP       $root_file (user choice)"
      elif [ -f "$TARGET_DIR/$root_file" ]; then
        ((scan_updated++))
        [ "$mode" = "print" ] && echo "  OVERWRITE  $root_file"
      else
        ((scan_initialized++))
        [ "$mode" = "print" ] && echo "  INIT       $root_file"
      fi
    fi
  done

  if [ "$mode" = "count" ]; then
    echo "$scan_updated $scan_preserved $scan_initialized"
  fi
}

# --- Main ---

echo ""
echo "Claude Development Framework — Update"
echo "======================================"
echo "Source: $SOURCE_DIR"
echo "Target: $TARGET_DIR"

if [ "$DRY_RUN" = true ]; then
  echo "Mode:   DRY RUN (no files will be modified)"
fi

# Step 0: Safety checks
check_git_status
check_claude_md

echo ""

if [ "$DRY_RUN" = true ]; then
  echo "Preview of changes:"
  echo ""
  scan_changes "print"

  read -r scan_u scan_p scan_i <<< "$(scan_changes count)"
  echo ""
  echo "Summary (dry run):"
  echo "  Would update:     $scan_u files"
  echo "  Would preserve:   $scan_p files (user data)"
  echo "  Would initialize: $scan_i files (new templates)"
  echo ""
  echo "Run without --dry-run to apply."
  exit 0
fi

# Step 0.5: Confirmation
read -r scan_u scan_p scan_i <<< "$(scan_changes count)"
echo "Planned changes:"
echo "  Update:     $scan_u files (framework)"
echo "  Preserve:   $scan_p files (user data)"
echo "  Initialize: $scan_i files (new templates)"
echo ""
echo "Backup will be created at:"
echo "  $BACKUP_DIR"
echo ""
read -rp "Proceed? [Y/n] " confirm
if [[ "$confirm" =~ ^[Nn]$ ]]; then
  echo "Aborted."
  exit 0
fi

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
    backup_file "$rel_path"
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

  # Everything else: backup then overwrite
  backup_file "$rel_path"
  mkdir -p "$target_dir"
  cp "$file" "$target_file"
  ((updated++))

done < <(find "$SOURCE_DIR/.claude" -type f -print0)

# Step 2: Copy root framework files
for root_file in CLAUDE.md .claude-project; do
  if [ -f "$SOURCE_DIR/$root_file" ]; then
    if [ "$root_file" = "CLAUDE.md" ] && [ "$CLAUDE_MD_ACTION" = "keep" ]; then
      ((preserved++))
      echo "  Kept CLAUDE.md (user choice)"
      continue
    fi
    backup_file "$root_file"
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

# Step 5: Clean up empty backup dir
if [ -d "$BACKUP_DIR" ] && [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
  rmdir "$BACKUP_DIR"
  backed_up=0
fi

# --- Report ---

echo ""
echo "Done."
echo "  Updated:     $updated files"
echo "  Preserved:   $preserved files (user data)"
echo "  Initialized: $initialized files (new templates)"
if [ "$backed_up" -gt 0 ]; then
  echo ""
  echo "  Backup: $BACKUP_DIR ($backed_up files)"
  echo "  To restore: cp -r $BACKUP_DIR/.claude/ $TARGET_DIR/.claude/"
fi
