#!/bin/bash

# This hook verifies that the agent has updated the "State of Truth" files 
# (GEMINI.md, PLANS.md, dependencies-map.md) if changes were made to the codebase.

# 1. Get staged changes (what is about to be committed/pushed)
STAGED_FILES=$(git diff --name-only --cached)

# 2. Identify if core code files changed
CODE_CHANGED=false
if echo "$STAGED_FILES" | grep -qE '^(lib/|android/|pubspec.yaml)'; then
    CODE_CHANGED=true
fi

# 3. Identify if State of Truth files changed
DOCS_CHANGED=false
if echo "$STAGED_FILES" | grep -qE '^(GEMINI.md|PLANS.md|dependencies-map.md)'; then
    DOCS_CHANGED=true
fi

# 4. Logic: If code changed but docs didn't, provide a warning/deny
if [ "$CODE_CHANGED" = true ] && [ "$DOCS_CHANGED" = false ]; then
    echo '{"decision": "deny", "reason": "Code changes detected but State of Truth (GEMINI.md, PLANS.md, dependencies-map.md) was not updated. Please review the plans and documentation to ensure they align with your changes before pushing."}'
    exit 0
fi

# 5. Allow if everything is in sync or no code changes
echo '{"decision": "allow"}'
exit 0
