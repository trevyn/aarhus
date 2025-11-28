#!/bin/bash
# Check that all theorems are registered in _proofRegistry

DEFINED=$(grep -E "^theorem " TodoUi/Basic.lean | sed 's/theorem //' | cut -d' ' -f1 | sort)
REGISTERED=$(grep "let _ := " TodoUi/Basic.lean | sed 's/.*:= //' | sed 's/TodoListUI\.//' | sed 's/Bounds\.//' | sort)

MISSING=$(comm -23 <(echo "$DEFINED") <(echo "$REGISTERED"))
EXTRA=$(comm -13 <(echo "$DEFINED") <(echo "$REGISTERED"))

if [ -n "$MISSING" ]; then
  echo "ERROR: Theorems NOT in registry:"
  echo "$MISSING" | sed 's/^/  /'
  exit 1
fi

if [ -n "$EXTRA" ]; then
  echo "WARNING: Registry entries that aren't theorems:"
  echo "$EXTRA" | sed 's/^/  /'
fi

echo "✓ All $(echo "$DEFINED" | wc -l) theorems are registered"
