#!/usr/bin/env python3
"""
Agda JSON Protocol - Interface for interacting with Agda holes via JSON

This provides a JSON-based protocol for working with Agda's interactive mode,
particularly for handling holes (goals) in Agda programs with cubical support.
"""

import json
import subprocess
import sys
import re
from typing import List, Dict, Any, Optional
from dataclasses import dataclass, asdict


@dataclass
class Hole:
    """Represents an Agda hole/goal"""
    id: int
    type: str
    context: List[str]
    location: Dict[str, Any]


@dataclass
class AgdaResponse:
    """Standard response format"""
    success: bool
    data: Any = None
    error: Optional[str] = None


class AgdaJSONProtocol:
    """JSON protocol handler for Agda interaction"""

    def __init__(self, agda_path: str = "agda"):
        self.agda_path = agda_path
        self.process: Optional[subprocess.Popen] = None

    def start(self, file_path: str) -> AgdaResponse:
        """Start Agda in interactive mode for a file"""
        try:
            self.process = subprocess.Popen(
                [self.agda_path, "--interaction", "--cubical", file_path],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1
            )
            return AgdaResponse(success=True, data={"message": f"Started Agda for {file_path}"})
        except Exception as e:
            return AgdaResponse(success=False, error=str(e))

    def send_command(self, command: str) -> str:
        """Send a command to Agda and get response"""
        if not self.process:
            raise RuntimeError("Agda process not started")

        self.process.stdin.write(command + "\n")
        self.process.stdin.flush()

        # Read response (simplified - real implementation needs proper parsing)
        response_lines = []
        while True:
            line = self.process.stdout.readline()
            if not line:
                break
            response_lines.append(line)
            # Check for response end marker
            if line.strip().startswith("(agda2-status-action"):
                break

        return "".join(response_lines)

    def load_file(self, file_path: str) -> AgdaResponse:
        """Load and type-check a file"""
        try:
            cmd = f'IOTCM "{file_path}" None Indirect (Cmd_load "{file_path}" [])'
            response = self.send_command(cmd)
            return AgdaResponse(success=True, data={"response": response})
        except Exception as e:
            return AgdaResponse(success=False, error=str(e))

    def get_goals(self) -> AgdaResponse:
        """Get all current goals/holes"""
        try:
            cmd = 'IOTCM "" None Indirect (Cmd_metas)'
            response = self.send_command(cmd)
            # Parse goals from response (simplified)
            return AgdaResponse(success=True, data={"goals": response})
        except Exception as e:
            return AgdaResponse(success=False, error=str(e))

    def goal_type(self, goal_id: int) -> AgdaResponse:
        """Get the type of a specific goal"""
        try:
            cmd = f'IOTCM "" None Indirect (Cmd_goal_type Simplified {goal_id} noRange "")'
            response = self.send_command(cmd)
            return AgdaResponse(success=True, data={"type": response})
        except Exception as e:
            return AgdaResponse(success=False, error=str(e))

    def refine(self, goal_id: int, expression: str = "") -> AgdaResponse:
        """Refine a goal with an optional expression"""
        try:
            cmd = f'IOTCM "" None Indirect (Cmd_refine_or_intro False {goal_id} noRange "{expression}")'
            response = self.send_command(cmd)
            return AgdaResponse(success=True, data={"refined": response})
        except Exception as e:
            return AgdaResponse(success=False, error=str(e))

    def give(self, goal_id: int, expression: str) -> AgdaResponse:
        """Fill a goal with a complete expression"""
        try:
            cmd = f'IOTCM "" None Indirect (Cmd_give WithoutForce {goal_id} noRange "{expression}")'
            response = self.send_command(cmd)
            return AgdaResponse(success=True, data={"given": response})
        except Exception as e:
            return AgdaResponse(success=False, error=str(e))

    def case_split(self, goal_id: int, variable: str) -> AgdaResponse:
        """Perform case split on a variable in a goal"""
        try:
            cmd = f'IOTCM "" None Indirect (Cmd_make_case {goal_id} noRange "{variable}")'
            response = self.send_command(cmd)
            return AgdaResponse(success=True, data={"cases": response})
        except Exception as e:
            return AgdaResponse(success=False, error=str(e))

    def auto(self, goal_id: int) -> AgdaResponse:
        """Try to automatically solve a goal using Agsy"""
        try:
            cmd = f'IOTCM "" None Indirect (Cmd_autoOne {goal_id} noRange "")'
            response = self.send_command(cmd)
            return AgdaResponse(success=True, data={"auto": response})
        except Exception as e:
            return AgdaResponse(success=False, error=str(e))

    def context(self, goal_id: int) -> AgdaResponse:
        """Get the context of a goal"""
        try:
            cmd = f'IOTCM "" None Indirect (Cmd_context Simplified {goal_id} noRange "")'
            response = self.send_command(cmd)
            return AgdaResponse(success=True, data={"context": response})
        except Exception as e:
            return AgdaResponse(success=False, error=str(e))

    def stop(self) -> AgdaResponse:
        """Stop the Agda process"""
        if self.process:
            self.process.terminate()
            self.process.wait()
            self.process = None
        return AgdaResponse(success=True, data={"message": "Agda process stopped"})


def handle_request(protocol: AgdaJSONProtocol, request: Dict[str, Any]) -> Dict[str, Any]:
    """Handle a JSON request"""
    command = request.get("command")
    params = request.get("params", {})

    handlers = {
        "start": lambda: protocol.start(params.get("file")),
        "load": lambda: protocol.load_file(params.get("file")),
        "goals": lambda: protocol.get_goals(),
        "goal_type": lambda: protocol.goal_type(params.get("goal_id")),
        "refine": lambda: protocol.refine(params.get("goal_id"), params.get("expression", "")),
        "give": lambda: protocol.give(params.get("goal_id"), params.get("expression")),
        "case": lambda: protocol.case_split(params.get("goal_id"), params.get("variable")),
        "auto": lambda: protocol.auto(params.get("goal_id")),
        "context": lambda: protocol.context(params.get("goal_id")),
        "stop": lambda: protocol.stop(),
    }

    handler = handlers.get(command)
    if not handler:
        return asdict(AgdaResponse(success=False, error=f"Unknown command: {command}"))

    try:
        response = handler()
        return asdict(response)
    except Exception as e:
        return asdict(AgdaResponse(success=False, error=str(e)))


def main():
    """Main REPL for JSON protocol"""
    protocol = AgdaJSONProtocol()

    print("Agda JSON Protocol started. Send JSON commands on stdin.", file=sys.stderr)
    print("Example: {\"command\": \"start\", \"params\": {\"file\": \"MyFile.agda\"}}", file=sys.stderr)

    for line in sys.stdin:
        try:
            request = json.loads(line)
            response = handle_request(protocol, request)
            print(json.dumps(response))
            sys.stdout.flush()
        except json.JSONDecodeError as e:
            error_response = asdict(AgdaResponse(success=False, error=f"Invalid JSON: {e}"))
            print(json.dumps(error_response))
            sys.stdout.flush()
        except Exception as e:
            error_response = asdict(AgdaResponse(success=False, error=str(e)))
            print(json.dumps(error_response))
            sys.stdout.flush()


if __name__ == "__main__":
    main()
