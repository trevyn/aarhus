#!/usr/bin/env python3
"""
Demo simulation of the Agda JSON protocol
Shows how the system would work with real Agda
"""

import json

# Simulated Agda responses for Example.agda
SIMULATED_RESPONSES = {
    "load": {
        "success": True,
        "data": {
            "message": "Loaded src/Example.agda",
            "goals": [0, 1, 2, 3],
            "warnings": [],
            "errors": []
        }
    },
    "goals": {
        "success": True,
        "data": {
            "goals": [
                {"id": 0, "line": 9, "col": 12, "type": "ℕ"},
                {"id": 1, "line": 13, "col": 23, "type": "x ≡ x"},
                {"id": 2, "line": 17, "col": 23, "type": "C"},
                {"id": 3, "line": 21, "col": 27, "type": "Σ A B"}
            ]
        }
    },
    "goal_type_0": {
        "success": True,
        "data": {
            "goal_id": 0,
            "type": "ℕ",
            "function": "addTwo",
            "context": ["n : ℕ"]
        }
    },
    "context_0": {
        "success": True,
        "data": {
            "goal_id": 0,
            "context": [
                "n : ℕ",
                "———————————————————————",
                "Goal: ℕ"
            ]
        }
    },
    "goal_type_1": {
        "success": True,
        "data": {
            "goal_id": 1,
            "type": "x ≡ x",
            "function": "pathExample",
            "context": ["A : Type", "x : A"]
        }
    },
    "context_1": {
        "success": True,
        "data": {
            "goal_id": 1,
            "context": [
                "A : Type",
                "x : A",
                "———————————————————————",
                "Goal: x ≡ x"
            ]
        }
    },
    "refine_1": {
        "success": True,
        "data": {
            "refined": "refl",
            "message": "Agda suggests: refl"
        }
    },
    "give_0": {
        "success": True,
        "data": {
            "accepted": True,
            "expression": "suc (suc n)",
            "message": "Solution accepted for goal 0"
        }
    }
}

def simulate_command(action, goal_id=None, expression=None):
    """Simulate Agda responses"""
    if action == "load":
        return SIMULATED_RESPONSES["load"]
    elif action == "goals":
        return SIMULATED_RESPONSES["goals"]
    elif action == "type" and goal_id is not None:
        key = f"goal_type_{goal_id}"
        return SIMULATED_RESPONSES.get(key, {
            "success": False,
            "error": f"Goal {goal_id} not found"
        })
    elif action == "context" and goal_id is not None:
        key = f"context_{goal_id}"
        return SIMULATED_RESPONSES.get(key, {
            "success": False,
            "error": f"Goal {goal_id} not found"
        })
    elif action == "refine" and goal_id is not None:
        key = f"refine_{goal_id}"
        return SIMULATED_RESPONSES.get(key, {
            "success": True,
            "data": {"refined": "?", "message": "No refinement available"}
        })
    elif action == "give" and goal_id is not None and expression:
        return {
            "success": True,
            "data": {
                "accepted": True,
                "expression": expression,
                "message": f"Solution '{expression}' accepted for goal {goal_id}"
            }
        }
    else:
        return {"success": False, "error": "Unknown command"}


print("=== Agda JSON Protocol Demo ===\n")

# Demo 1: Load file
print("1. Loading src/Example.agda...")
result = simulate_command("load")
print(json.dumps(result, indent=2))
print()

# Demo 2: List goals
print("2. Listing all goals/holes...")
result = simulate_command("goals")
print(json.dumps(result, indent=2))
print()

# Demo 3: Get type of goal 0
print("3. Getting type of goal 0 (addTwo function)...")
result = simulate_command("type", 0)
print(json.dumps(result, indent=2))
print()

# Demo 4: Get context of goal 0
print("4. Getting context of goal 0...")
result = simulate_command("context", 0)
print(json.dumps(result, indent=2))
print()

# Demo 5: Get type of goal 1 (cubical path)
print("5. Getting type of goal 1 (pathExample - cubical equality)...")
result = simulate_command("type", 1)
print(json.dumps(result, indent=2))
print()

# Demo 6: Refine goal 1
print("6. Refining goal 1 (let Agda suggest)...")
result = simulate_command("refine", 1)
print(json.dumps(result, indent=2))
print()

# Demo 7: Give solution to goal 0
print("7. Giving solution to goal 0: 'suc (suc n)'...")
result = simulate_command("give", 0, "suc (suc n)")
print(json.dumps(result, indent=2))
print()

print("=== Demo Complete ===")
print("\nThis demonstrates the JSON protocol workflow.")
print("With Agda installed, these would be real interactions!")
print("\nSee README.md for full API documentation.")
