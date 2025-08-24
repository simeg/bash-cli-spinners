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

# Run the demo
./demo.sh
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

- Basic: `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`
- Bright: `bright_red`, `bright_green`, `bright_yellow`, `bright_blue`,
`bright_magenta`, `bright_cyan`, `bright_white`

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

