#!/usr/bin/env python3
"""
Simple CLI for querying Agda holes without an IDE

Usage:
    ./agda-cli.py <file.agda> goals           # List all holes
    ./agda-cli.py <file.agda> type <n>        # Get type of hole n
    ./agda-cli.py <file.agda> context <n>     # Get context of hole n
    ./agda-cli.py <file.agda> refine <n> [expr]  # Refine hole n
    ./agda-cli.py <file.agda> give <n> <expr>    # Give solution to hole n
"""

import sys
import json
import subprocess
import argparse


def query_agda(file_path: str, action: str, **kwargs):
    """Query Agda using the JSON protocol"""
    protocol_script = "agda-json-protocol.py"

    requests = [
        {"command": "start", "params": {"file": file_path}},
        {"command": "load", "params": {"file": file_path}},
    ]

    if action == "goals":
        requests.append({"command": "goals"})
    elif action == "type":
        requests.append({"command": "goal_type", "params": {"goal_id": kwargs["goal_id"]}})
    elif action == "context":
        requests.append({"command": "context", "params": {"goal_id": kwargs["goal_id"]}})
    elif action == "refine":
        requests.append({
            "command": "refine",
            "params": {
                "goal_id": kwargs["goal_id"],
                "expression": kwargs.get("expression", "")
            }
        })
    elif action == "give":
        requests.append({
            "command": "give",
            "params": {
                "goal_id": kwargs["goal_id"],
                "expression": kwargs["expression"]
            }
        })

    requests.append({"command": "stop"})

    # Send requests to protocol
    proc = subprocess.Popen(
        ["python3", protocol_script],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )

    for req in requests:
        proc.stdin.write(json.dumps(req) + "\n")

    proc.stdin.close()

    responses = []
    for line in proc.stdout:
        try:
            responses.append(json.loads(line))
        except:
            pass

    proc.wait()

    return responses


def simple_agda_query(file_path: str):
    """Simple query using agda directly"""
    try:
        # Just load the file and show info
        result = subprocess.run(
            ["agda", "--interaction-json", "--cubical"],
            input=f'IOTCM "{file_path}" None Indirect (Cmd_load "{file_path}" [])\n',
            capture_output=True,
            text=True,
            timeout=10
        )

        print("=== Agda Output ===")
        print(result.stdout)
        if result.stderr:
            print("\n=== Errors ===")
            print(result.stderr)

    except subprocess.TimeoutExpired:
        print("Agda timed out")
    except FileNotFoundError:
        print("Error: agda not found in PATH")
        print("Install Agda: https://agda.readthedocs.io/en/latest/getting-started/installation.html")
    except Exception as e:
        print(f"Error: {e}")


def main():
    parser = argparse.ArgumentParser(description="Query Agda holes from command line")
    parser.add_argument("file", help="Agda file to query")
    parser.add_argument("action", choices=["goals", "type", "context", "refine", "give", "check"],
                       help="Action to perform")
    parser.add_argument("goal_id", nargs="?", type=int, help="Goal ID (for type/context/refine/give)")
    parser.add_argument("expression", nargs="?", help="Expression (for refine/give)")

    args = parser.parse_args()

    if args.action == "check":
        simple_agda_query(args.file)
    else:
        kwargs = {}
        if args.goal_id is not None:
            kwargs["goal_id"] = args.goal_id
        if args.expression:
            kwargs["expression"] = args.expression

        responses = query_agda(args.file, args.action, **kwargs)

        print(json.dumps(responses, indent=2))


if __name__ == "__main__":
    if len(sys.argv) == 1:
        print(__doc__)
        sys.exit(1)
    main()
