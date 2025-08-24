# bash-cli-spinners
> +80 spinners for use in the terminal


<p align="center">
        <br>
        <img width="700" src="assets/demo.svg">
        <br>
        <br>
    </p>

A bash/zsh cli spinner library **heavily inspired** by
[cli-spinners](https://github.com/sindresorhus/cli-spinners).

**🌐 <a href="https://simeg.github.io/bash-cli-spinners/" target="_blank">View Live Demo of all spinners</a> 🌐**

## Features

- **+80 spinners** from the official cli-spinners collection
- **JSON-based** - Easy to extend and maintain
- **Accurate timing** - Uses the official intervals from cli-spinners
- **Color support** - 14 different colors available
- **Two modes** - Show for duration or run with command
- **Clean output** - Proper cursor management and cleanup
- **Web gallery** - Interactive browser interface to preview all spinners

## Requirements

- `bash` 4.0+
- `jq` for JSON parsing
- `bc` for precise timing calculations

Install requirements:
```bash
# macOS
brew install jq bc

# Ubuntu/Debian
sudo apt install jq bc
```

## Quick Start

```bash
# List all available spinners
./spinner.sh list

# Show a spinner for 5 seconds
./spinner.sh show dots 5 "Loading data" blue

# Run a command with a spinner
./spinner.sh run pong "Installing packages" bright_green sleep 10
```

## Usage

### Basic Usage
```bash
./spinner.sh show <spinner_name> <duration> [message] [color]
./spinner.sh run <spinner_name> [message] [color] <command>
```

### Examples
```bash
# Simple 3-second dots spinner
./spinner.sh show dots 3

# Pong game with custom message and color
./spinner.sh show pong 5 "Playing pong!" bright_green

# Weather spinner while downloading
./spinner.sh run weather "Downloading files" cyan curl -O https://example.com/file.zip

# Material design spinner while compiling
./spinner.sh run material "Compiling project" bright_blue make build
```

## Available Colors

### Basic Colors
![red](https://img.shields.io/badge/red-red?style=flat&color=CD5C5C) ![green](https://img.shields.io/badge/green-green?style=flat&color=228B22) ![yellow](https://img.shields.io/badge/yellow-yellow?style=flat&color=DAA520) ![blue](https://img.shields.io/badge/blue-blue?style=flat&color=4169E1) ![magenta](https://img.shields.io/badge/magenta-magenta?style=flat&color=DA70D6) ![cyan](https://img.shields.io/badge/cyan-cyan?style=flat&color=20B2AA) ![white](https://img.shields.io/badge/white-white?style=flat&color=F5F5F5)

### Bright Colors
![bright_red](https://img.shields.io/badge/bright__red-bright_red?style=flat&color=FF6B6B) ![bright_green](https://img.shields.io/badge/bright__green-bright_green?style=flat&color=51CF66) ![bright_yellow](https://img.shields.io/badge/bright__yellow-bright_yellow?style=flat&color=FFD93D) ![bright_blue](https://img.shields.io/badge/bright__blue-bright_blue?style=flat&color=74C0FC) ![bright_magenta](https://img.shields.io/badge/bright__magenta-bright_magenta?style=flat&color=F783AC) ![bright_cyan](https://img.shields.io/badge/bright__cyan-bright_cyan?style=flat&color=66D9EF) ![bright_white](https://img.shields.io/badge/bright__white-bright_white?style=flat&color=FFFFFF)

## Installation

### For Use in Your Own Scripts

To integrate this spinner library into your own bash/zsh scripts, you need both
core files:

1. **Download the required files:**
   ```bash
   # Download spinner engine
   curl -O https://raw.githubusercontent.com/simeg/bash-cli-spinners/main/spinner.sh

   # Download spinners database
   curl -O https://raw.githubusercontent.com/simeg/bash-cli-spinners/main/spinners.json
   ```

2. **Make spinner.sh executable:**
   ```bash
   chmod +x spinner.sh
   ```

3. **Use in your scripts:**
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail

   # Bring spinner functions into *this* shell
   source ./spinner.sh

   my_function() {
     # your real logic here
     sleep 10
   }

   # Run a finite task with a spinner
   run_with_spinner "pong" "Installing" "cyan" my_function

   # Or pass a normal command directly (no function needed)
   run_with_spinner "dots" "Building assets" "blue" npm run build
   ```

## Architecture

### JSON Structure

Each spinner in `spinners.json` follows this format:
```json
{
  "spinner_name": {
    "interval": 80,
    "frames": ["frame1", "frame2", "frame3"]
  }
}
```

- `interval`: Time between frames in milliseconds
- `frames`: Array of strings/characters to display

## Advanced Usage

### Sourcing Functions

You can source the spinner script to use functions directly:

```bash
source spinner.sh

# Use functions directly
show_spinner "dots" 5 "Custom loading" "blue"
run_with_spinner "pong" "Background task" "green" sleep 10
```

### Adding Custom Spinners

Edit `spinners.json` to add your own spinners:

```json
{
  "custom": {
    "interval": 100,
    "frames": ["(o)", "(O)", "(0)", "(O)"]
  }
}
```

## Related

- [cli-spinners](https://github.com/sindresorhus/cli-spinners)

