#!/bin/bash

# Comprehensive demo showing all specified spinners replacing each other in
# place

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPINNER_SCRIPT="$SCRIPT_DIR/spinner.sh"

# All requested spinners with colors (duration calculated dynamically)
spinners=(
    # Dots family (Braille patterns)
    "dots:blue"
    "dots2:bright_blue"
    "dots3:cyan"
    "dots4:bright_cyan"
    "dots5:green"
    "dots6:bright_green"
    "dots7:yellow"
    "dots8:bright_yellow"
    "dots9:red"
    "dots10:bright_red"
    "dots11:magenta"
    "dots12:bright_magenta"

    # Lines and pipes
    "line:white"
    "line2:bright_white"
    "pipe:blue"

    # Simple dots
    "simpleDots:green"
    "simpleDotsScrolling:bright_green"

    # Stars
    "star:yellow"
    "star2:bright_yellow"

    # Animations
    "flip:cyan"
    "hamburger:red"

    # Growing
    "growVertical:blue"
    "growHorizontal:bright_blue"

    # Balloons
    "balloon:magenta"
    "balloon2:bright_magenta"

    # Effects
    "noise:white"
    "bounce:green"

    # Box bouncing
    "boxBounce:red"
    "boxBounce2:bright_red"

    # Shapes
    "triangle:yellow"
    "arc:cyan"
    "circle:blue"
    "squareCorners:magenta"
    "circleQuarters:green"
    "circleHalves:red"
    "squish:white"

    # Toggles
    "toggle:blue"
    "toggle2:bright_blue"
    "toggle3:cyan"
    "toggle4:bright_cyan"
    "toggle5:green"
    "toggle6:bright_green"
    "toggle7:yellow"
    "toggle8:bright_yellow"
    "toggle9:red"
    "toggle10:bright_red"
    "toggle11:magenta"
    "toggle12:bright_magenta"
    "toggle13:white"

    # Arrows
    "arrow:blue"
    "arrow2:bright_blue"
    "arrow3:cyan"

    # Bouncing
    "bouncingBar:green"
    "bouncingBall:bright_green"

    # Emoji animations
    "smiley:yellow"
    "monkey:bright_yellow"
    "hearts:bright_magenta"
    "clock:blue"
    "earth:bright_blue"
    "moon:cyan"
    "runner:green"

    # Complex animations
    "pong:bright_green"
    "shark:bright_blue"

    # Others
    "dqpb:red"
    "weather:bright_yellow"
    "christmas:bright_green"
)

# Hide cursor at start
printf "\033[?25l"

# Set trap to restore cursor on exit
trap 'printf "\033[?25h\033[0m"; exit' EXIT INT TERM

# Track progress
total=${#spinners[@]}
current=0

for spinner_config in "${spinners[@]}"; do
    current=$((current + 1))
    IFS=':' read -r name color <<< "$spinner_config"

    # Get frames array
    frame_array=()
    while IFS= read -r line; do
        frame_array+=("$line")
    done <<< "$(jq -r ".\"$name\".frames[]" "$SCRIPT_DIR/spinners.json" 2>/dev/null)"
    frame_count=${#frame_array[@]}

    if [[ $frame_count -eq 0 ]]; then
        continue
    fi

    # Get interval and convert to sleep time
    interval=$(jq -r ".\"$name\".interval" "$SCRIPT_DIR/spinners.json" 2>/dev/null)
    sleep_time=$(echo "scale=3; $interval / 1000" | bc -l 2>/dev/null || echo "0.1")

    # Calculate dynamic duration based on frame count
    # For spinners with few frames (1-4): show 3 complete cycles
    # For spinners with medium frames (5-10): show 2 complete cycles
    # For spinners with many frames (11+): show 1 complete cycle
    if [[ $frame_count -le 4 ]]; then
        cycles=3
    elif [[ $frame_count -le 10 ]]; then
        cycles=2
    else
        cycles=1
    fi

    # Calculate total duration: cycles * frames * interval_per_frame
    duration=$(echo "scale=3; $cycles * $frame_count * $interval / 1000" | bc -l 2>/dev/null)
    duration=${duration%.*}  # Remove decimal part for integer seconds
    duration=$((duration + 1))  # Add 1 second minimum

    # Set up colors
    color_code=""
    reset_code=""
    case "$color" in
        "red") color_code="\033[31m" ;;
        "green") color_code="\033[32m" ;;
        "yellow") color_code="\033[33m" ;;
        "blue") color_code="\033[34m" ;;
        "magenta") color_code="\033[35m" ;;
        "cyan") color_code="\033[36m" ;;
        "white") color_code="\033[37m" ;;
        "bright_red") color_code="\033[91m" ;;
        "bright_green") color_code="\033[92m" ;;
        "bright_yellow") color_code="\033[93m" ;;
        "bright_blue") color_code="\033[94m" ;;
        "bright_magenta") color_code="\033[95m" ;;
        "bright_cyan") color_code="\033[96m" ;;
        "bright_white") color_code="\033[97m" ;;
    esac
    reset_code="\033[0m"

    # Run spinner animation for calculated duration
    start_time=$(date +%s)
    end_time=$((start_time + duration))
    frame_index=0

    while [[ $(date +%s) -lt $end_time ]]; do
        current_frame="${frame_array[$frame_index]}"
        printf "\r${color_code}%s${reset_code} ${name}\033[K" "$current_frame"

        frame_index=$(( (frame_index + 1) % frame_count ))
        sleep "$sleep_time"
    done
done

# Clear the line and restore cursor
printf "\r\033[K"
printf "\033[?25h\033[0m"
