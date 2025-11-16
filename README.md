# aarhus

Agda with Cubical Type Theory + JSON Protocol for Holes

## What is this?

This project provides a **JSON-based protocol** for interacting with Agda holes (goals) **without needing an IDE**. You can query holes, get their types, contexts, and work with them programmatically.

## Features

- 🎯 Query Agda holes from command line
- 🔄 JSON protocol for programmatic interaction
- 📦 Cubical type theory support
- 🚀 No IDE required - just terminal or scripts

## Setup

### Prerequisites

1. Install Agda: https://agda.readthedocs.io/en/latest/getting-started/installation.html
2. Install cubical library:
   ```bash
   git clone https://github.com/agda/cubical.git
   cd cubical
   make install
   ```

3. Make CLI executable:
   ```bash
   chmod +x agda-cli.py agda-json-protocol.py
   ```

## Usage

### Quick Start

Check an Agda file with holes:
```bash
./agda-cli.py src/Example.agda check
```

### JSON Protocol Commands

The `agda-json-protocol.py` reads JSON from stdin and outputs JSON responses:

```bash
# Start interactive session
echo '{"command": "start", "params": {"file": "src/Example.agda"}}' | python3 agda-json-protocol.py
```

### CLI Tool

```bash
# List all goals/holes in a file
./agda-cli.py src/Example.agda goals

# Get type of hole #0
./agda-cli.py src/Example.agda type 0

# Get context of hole #0
./agda-cli.py src/Example.agda context 0

# Refine hole #0 (let Agda try to help)
./agda-cli.py src/Example.agda refine 0

# Give a specific solution to hole #0
./agda-cli.py src/Example.agda give 0 "suc (suc n)"
```

## JSON Protocol API

Send newline-delimited JSON on stdin, get responses on stdout.

### Commands

**start** - Start Agda for a file
```json
{"command": "start", "params": {"file": "path/to/file.agda"}}
```

**load** - Load and typecheck a file
```json
{"command": "load", "params": {"file": "path/to/file.agda"}}
```

**goals** - List all holes/goals
```json
{"command": "goals"}
```

**goal_type** - Get type of a specific goal
```json
{"command": "goal_type", "params": {"goal_id": 0}}
```

**context** - Get context of a goal
```json
{"command": "context", "params": {"goal_id": 0}}
```

**refine** - Refine a goal (auto-complete)
```json
{"command": "refine", "params": {"goal_id": 0, "expression": ""}}
```

**give** - Provide solution to a goal
```json
{"command": "give", "params": {"goal_id": 0, "expression": "refl"}}
```

**case** - Case split on a variable
```json
{"command": "case", "params": {"goal_id": 0, "variable": "x"}}
```

**auto** - Try automatic solving (Agsy)
```json
{"command": "auto", "params": {"goal_id": 0}}
```

**stop** - Stop Agda process
```json
{"command": "stop"}
```

### Response Format

All responses follow this structure:
```json
{
  "success": true,
  "data": {...},
  "error": null
}
```

On error:
```json
{
  "success": false,
  "data": null,
  "error": "Error message"
}
```

## Example Workflow

```bash
# 1. Check file has holes
./agda-cli.py src/Example.agda check

# 2. List goals
./agda-cli.py src/Example.agda goals

# 3. Inspect goal #0
./agda-cli.py src/Example.agda type 0
./agda-cli.py src/Example.agda context 0

# 4. Fill hole
./agda-cli.py src/Example.agda give 0 "suc (suc n)"
```

## Example Agda File

See `src/Example.agda` for examples of holes with cubical features:
- Simple function holes
- Path equality (cubical)
- Function composition
- Dependent pairs

## Project Structure

```
aarhus/
├── aarhus.agda-lib          # Agda library config
├── agda-json-protocol.py    # JSON protocol server
├── agda-cli.py              # Command-line tool
├── src/
│   └── Example.agda         # Example file with holes
└── README.md
```

## Why?

- **Automation**: Script Agda proof development
- **CI/CD**: Check proofs in pipelines
- **Tooling**: Build custom tools on top of Agda
- **Learning**: Explore holes programmatically
- **No IDE**: Terminal-first workflow

## Capisce? 🤌

You can now speak JSON to Agda holes!
