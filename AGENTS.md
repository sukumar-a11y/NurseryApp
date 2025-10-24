#!/bin/bash
# Enforce a simple Conventional Commits style on the first line of commit messages.
# Accepts: type(scope): subject  or  type: subject
# Allowed types: feat, fix, chore, docs, refactor, test, perf, style

MSG_FILE="$1"
if [ -z "$MSG_FILE" ]; then
  echo "commit-msg hook: no message file provided"
  exit 0
fi

# Read only the first line of the commit message
FIRST_LINE=$(sed -n '1p' "$MSG_FILE" | tr -d '\r')

# Regex explanation:
# ^(feat|fix|chore|docs|refactor|test|perf|style)    -> allowed type
# (\([a-z0-9_/-]+\))?                            -> optional scope with lowercase/nums/hyphen/underscore/slash
# :[[:space:]]+                                       -> colon + one or more whitespace characters (POSIX-compatible)
# .{1,}                                              -> subject (at least 1 char)

if [[ ! "$FIRST_LINE" =~ ^(feat|fix|chore|docs|refactor|test|perf|style)(\([a-z0-9_/-]+\))?:[[:space:]]+.+ ]]; then
  cat <<EOF
ERROR: Invalid commit message format.

Expected: <type>(<scope>): <subject>
 - type: feat, fix, chore, docs, refactor, test, perf, style
 - scope: optional, lowercase, can include numbers, hyphens, underscores, or slashes
 - subject: short imperative description

Examples:
  feat(ui): add plant list
  fix: correct typo in README

Please update your commit message.
EOF
  exit 1
fi

# Optionally, enforce subject length (first line) <= 72 chars
if [ ${#FIRST_LINE} -gt 72 ]; then
  echo "ERROR: Commit message subject is longer than 72 characters (current: ${#FIRST_LINE}). Please keep it concise."
  exit 1
fi

exit 0
