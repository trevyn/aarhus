# Agda Holes CLI Tool

A command-line tool for querying holes (goals/interaction points) in Agda files.

## Features

- Lists all holes in an Agda file
- Shows the type expected for each hole
- Displays position information for each hole
- Optional verbose mode to show context information

## Building

```bash
cabal build
```

## Usage

```bash
cabal run agda-holes -- <file.agda> [--verbose]
```

Or after building:

```bash
agda-holes example.agda
agda-holes example.agda --verbose
```

## Example

Given an Agda file with holes:

```agda
length : {A : Set} → List A → ℕ
length [] = zero
length (x ∷ xs) = {!!}
```

Running the tool will display:

```
Found 1 hole(s):

Hole #1 (ID: ...)
  Position: ...
  Type: ℕ
```

## Requirements

- GHC (Haskell compiler)
- Agda >= 2.6.0
- cabal-install