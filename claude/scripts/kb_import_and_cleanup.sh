#!/usr/bin/env bash
set -euo pipefail

# Import a markdown file into kb, verify the import, then delete source files.
#
# Usage: kb_import_and_cleanup.sh <type> <file_to_import> [files_to_delete...]
#
# Arguments:
#   type             - kb document type (e.g., "plan", "research")
#   file_to_import   - markdown file to import into kb
#   files_to_delete  - additional files to delete after successful import
#                      (the imported file is always deleted)
#
# The script will:
#   1. Import the file into kb
#   2. Extract the new document ID from import output
#   3. Retrieve the document back and verify it has content
#   4. Only then delete the source files
#   5. Print the kb document ID on success

KB="${HOME}/.claude/bin/kb"
DB="kb.db"
MIN_VERIFY_LENGTH=50

usage() {
  echo "Usage: $0 <type> <file_to_import> [files_to_delete...]" >&2
  echo "  type            - kb document type (plan, research)" >&2
  echo "  file_to_import  - markdown file to import" >&2
  echo "  files_to_delete - additional files to remove after import" >&2
  exit 1
}

if [[ $# -lt 2 ]]; then
  usage
fi

TYPE="$1"
FILE_TO_IMPORT="$2"
shift 2
EXTRA_FILES=("$@")

# Validate input file exists and is non-empty
if [[ ! -f "$FILE_TO_IMPORT" ]]; then
  echo "ERROR: File not found: $FILE_TO_IMPORT" >&2
  exit 1
fi

if [[ ! -s "$FILE_TO_IMPORT" ]]; then
  echo "ERROR: File is empty: $FILE_TO_IMPORT" >&2
  exit 1
fi

# Import into kb
if ! IMPORT_OUTPUT=$("$KB" import "$FILE_TO_IMPORT" -t "$TYPE" --db "$DB" --plain 2>&1); then
  echo "ERROR: kb import failed:" >&2
  echo "$IMPORT_OUTPUT" >&2
  exit 1
fi

# Extract document ID from output like "Imported document 42: title"
DOC_ID=$(echo "$IMPORT_OUTPUT" | grep -oE 'Imported document ([0-9]+)' | grep -oE '[0-9]+')
if [[ -z "$DOC_ID" ]]; then
  echo "ERROR: Could not extract document ID from import output:" >&2
  echo "$IMPORT_OUTPUT" >&2
  exit 1
fi

# Verify the document was stored correctly by retrieving it
if ! VERIFY_OUTPUT=$("$KB" get "$DOC_ID" --db "$DB" --plain 2>&1); then
  echo "ERROR: Failed to verify document $DOC_ID after import:" >&2
  echo "$VERIFY_OUTPUT" >&2
  exit 1
fi

# Check that retrieved content is non-trivial
CONTENT_LENGTH=${#VERIFY_OUTPUT}
if [[ $CONTENT_LENGTH -lt $MIN_VERIFY_LENGTH ]]; then
  echo "ERROR: Verification failed — retrieved document $DOC_ID has only $CONTENT_LENGTH chars (expected ${MIN_VERIFY_LENGTH}+)" >&2
  echo "Document preserved in kb as ID $DOC_ID but source files NOT deleted." >&2
  exit 1
fi

# All verified — now delete source files
DELETED_FILES=()

rm -f "$FILE_TO_IMPORT"
DELETED_FILES+=("$FILE_TO_IMPORT")

if [[ ${#EXTRA_FILES[@]} -gt 0 ]]; then
  for f in "${EXTRA_FILES[@]}"; do
    if [[ -f "$f" ]]; then
      rm -f "$f"
      DELETED_FILES+=("$f")
    fi
  done
fi

echo "Successfully imported as kb document $DOC_ID (type: $TYPE)"
echo "Verified: $CONTENT_LENGTH chars retrieved"
echo "Deleted ${#DELETED_FILES[@]} file(s): ${DELETED_FILES[*]}"
echo "KB_DOC_ID=$DOC_ID"
