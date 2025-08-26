#!/bin/bash

# JSON-based Bash Loading Spinner Engine
# Based on cli-spinners: https://github.com/sindresorhus/cli-spinners

# shellcheck disable=SC2034  # Some variables may appear unused in specific conditions

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPINNERS_JSON="$SCRIPT_DIR/spinners.json"

# Performance optimization: Cache parsed data (requires bash 4.0+)
if [[ "${BASH_VERSION%%.*}" -ge 4 ]]; then
    declare -A SPINNER_FRAMES_CACHE
    declare -A SPINNER_INTERVAL_CACHE
    CACHE_ENABLED=true
else
    CACHE_ENABLED=false
fi
CACHE_LOADED=false

# Check if jq is available for JSON parsing
if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required for JSON parsing. Install with: brew install jq (macOS) or apt install jq (Ubuntu)" >&2
    exit 1
fi

# Check if spinners.json exists
if [[ ! -f "$SPINNERS_JSON" ]]; then
    echo "Error: spinners.json not found at $SPINNERS_JSON" >&2
    exit 1
fi

# Load all spinner data into cache for performance
load_spinner_cache() {
    if [[ "$CACHE_LOADED" == "true" ]]; then
        return 0
    fi

    # Skip caching if not supported
    if [[ "$CACHE_ENABLED" != "true" ]]; then
        CACHE_LOADED=true
        return 0
    fi

    local spinner_names
    if ! spinner_names=$(jq -r 'keys[]' "$SPINNERS_JSON" 2>/dev/null); then
        echo "Error: Failed to parse spinners.json" >&2
        return 1
    fi

    while IFS= read -r spinner_name; do
        [[ -z "$spinner_name" ]] && continue

        # Cache frames (joined with newlines for storage)
        local frames
        frames=$(jq -r ".\"$spinner_name\".frames[]" "$SPINNERS_JSON" 2>/dev/null | tr '\n' '\0')
        SPINNER_FRAMES_CACHE["$spinner_name"]="$frames"

        # Cache interval
        local interval
        interval=$(jq -r ".\"$spinner_name\".interval" "$SPINNERS_JSON" 2>/dev/null)
        SPINNER_INTERVAL_CACHE["$spinner_name"]="$interval"

    done <<< "$spinner_names"

    CACHE_LOADED=true
}

# List all available spinners
list_spinners() {
    echo "Available spinners:"
    jq -r 'keys[]' "$SPINNERS_JSON" | sort
}

# Get spinner data (updated to work with cache)
get_spinner_data() {
    local spinner_name="$1"

    if [[ "$CACHE_ENABLED" == "true" ]]; then
        load_spinner_cache || return 1

        if [[ -z "${SPINNER_FRAMES_CACHE[$spinner_name]:-}" ]]; then
            echo "Error: Spinner '$spinner_name' not found" >&2
            return 1
        fi

        # Return cached data in JSON format for compatibility
        local frames_json
        frames_json=$(printf '%s' "${SPINNER_FRAMES_CACHE[$spinner_name]}" | tr '\0' '\n' | sed 's/.*/"&"/' | tr '\n' ',' | sed 's/,$//')
        echo "{\"interval\":${SPINNER_INTERVAL_CACHE[$spinner_name]},\"frames\":[$frames_json]}"
    else
        # Fallback to direct JSON parsing
        if ! jq -e ".\"$spinner_name\"" "$SPINNERS_JSON" >/dev/null 2>&1; then
            echo "Error: Spinner '$spinner_name' not found" >&2
            return 1
        fi
        jq -r ".\"$spinner_name\"" "$SPINNERS_JSON"
    fi
}

# Get spinner frames (optimized with cache)
get_frames() {
    local spinner_name="$1"

    # Use cache if available
    if [[ "$CACHE_ENABLED" == "true" ]]; then
        load_spinner_cache || return 1

        if [[ -z "${SPINNER_FRAMES_CACHE[$spinner_name]:-}" ]]; then
            return 1
        fi

        printf '%s' "${SPINNER_FRAMES_CACHE[$spinner_name]}" | tr '\0' '\n'
    else
        # Fallback to direct JSON parsing
        jq -r ".\"$spinner_name\".frames[]" "$SPINNERS_JSON" 2>/dev/null
    fi
}

# Get spinner interval (optimized with cache)
get_interval() {
    local spinner_name="$1"

    # Use cache if available
    if [[ "$CACHE_ENABLED" == "true" ]]; then
        load_spinner_cache || return 1
        echo "${SPINNER_INTERVAL_CACHE[$spinner_name]:-}"
    else
        # Fallback to direct JSON parsing
        jq -r ".\"$spinner_name\".interval" "$SPINNERS_JSON" 2>/dev/null
    fi
}

# Convert milliseconds to seconds for bash sleep
ms_to_seconds() {
    local ms="$1"
    echo "scale=3; $ms / 1000" | bc -l 2>/dev/null || echo "0.1"
}

# Show spinner for a specified duration
show_spinner() {
    local spinner_name="$1"
    local duration="$2"
    local message="${3:-Loading}"
    local color="${4:-}"
    local demo_mode="${5:-false}"

    # Validate inputs
    if [[ -z "$spinner_name" ]]; then
        echo "Usage: show_spinner <spinner_name> <duration> [message] [color]" >&2
        return 1
    fi

    if [[ -z "$duration" ]] || ! [[ "$duration" =~ ^[0-9]+$ ]]; then
        echo "Error: Duration must be a positive integer (seconds)" >&2
        return 1
    fi

    # Get spinner data
    local frames interval sleep_time
    if ! frames=$(get_frames "$spinner_name"); then
        echo "Error: Failed to get frames for spinner '$spinner_name'" >&2
        return 1
    fi

    if ! interval=$(get_interval "$spinner_name"); then
        echo "Error: Failed to get interval for spinner '$spinner_name'" >&2
        return 1
    fi

    # Convert interval to sleep time
    sleep_time=$(ms_to_seconds "$interval")

    # Convert frames to array (compatible with older bash)
    local frame_array=()
    while IFS= read -r line; do
        frame_array+=("$line")
    done <<< "$frames"
    local frame_count=${#frame_array[@]}

    if [[ $frame_count -eq 0 ]]; then
        echo "Error: No frames found for spinner '$spinner_name'" >&2
        return 1
    fi

    # Set up colors if specified
    local color_code="" reset_code=""
    if [[ -n "$color" ]]; then
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
    fi

    # Hide cursor
    printf "\033[?25l"

    # Set up trap to restore cursor on exit
    trap 'printf "\033[?25h\033[0m"; exit' EXIT INT TERM

    # Run spinner animation
    local start_time
    start_time=$(date +%s)
    local end_time=$((start_time + duration))
    local frame_index=0

    while [[ $(date +%s) -lt $end_time ]]; do
        local current_frame="${frame_array[$frame_index]}"
        printf "\r${color_code}%s${reset_code} ${message}\033[K" "$current_frame"

        frame_index=$(( (frame_index + 1) % frame_count ))
        sleep "$sleep_time"
    done

    # Clear line and restore cursor
    printf "\r\033[K"
    printf "\033[?25h%s" "${reset_code}"
}

# Run spinner while executing a command
run_with_spinner() {
    local spinner_name="$1"
    local message="${2:-Loading}"
    local color="${3:-}"
    shift 3
    local command=("$@")

    if [[ ${#command[@]} -eq 0 ]]; then
        echo "Usage: run_with_spinner <spinner_name> [message] [color] <command>" >&2
        return 1
    fi

    # Get spinner data
    local frames interval sleep_time
    if ! frames=$(get_frames "$spinner_name"); then
        echo "Error: Failed to get frames for spinner '$spinner_name'" >&2
        return 1
    fi

    if ! interval=$(get_interval "$spinner_name"); then
        echo "Error: Failed to get interval for spinner '$spinner_name'" >&2
        return 1
    fi

    sleep_time=$(ms_to_seconds "$interval")

    # Convert frames to array (compatible with older bash)
    local frame_array=()
    while IFS= read -r line; do
        frame_array+=("$line")
    done <<< "$frames"
    local frame_count=${#frame_array[@]}

    # Set up colors
    local color_code="" reset_code=""
    if [[ -n "$color" ]]; then
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
    fi

    # Start command in background
    "${command[@]}" &
    local cmd_pid=$!

    # Hide cursor
    printf "\033[?25l"

    # Set up trap to restore cursor and cleanup
    trap 'printf "\033[?25h\033[0m"; kill $cmd_pid 2>/dev/null; exit' EXIT INT TERM

    # Run spinner while command executes
    local frame_index=0
    while kill -0 "$cmd_pid" 2>/dev/null; do
        local current_frame="${frame_array[$frame_index]}"
        printf "\r${color_code}%s${reset_code} ${message}\033[K" "$current_frame"

        frame_index=$(( (frame_index + 1) % frame_count ))
        sleep "$sleep_time"
    done

    # Wait for command to complete and get exit code
    wait "$cmd_pid"
    local exit_code=$?

    # Clear line and restore cursor
    printf "\r\033[K"
    printf "\033[?25h%s" "${reset_code}"

    return $exit_code
}

# Main function for CLI usage
main() {
    case "${1:-}" in
        "list"|"ls")
            list_spinners
            ;;
        "show")
            shift
            show_spinner "$@"
            ;;
        "run")
            shift
            run_with_spinner "$@"
            ;;
        "help"|"--help"|"-h"|"")
            echo "JSON-based Bash Loading Spinner Engine"
            echo ""
            echo "Usage:"
            echo "  $0 list                                    - List all available spinners"
            echo "  $0 show <name> <duration> [message] [color] - Show spinner for duration (seconds)"
            echo "  $0 run <name> [message] [color] <command>    - Run command with spinner"
            echo ""
            echo "Examples:"
            echo "  $0 list"
            echo "  $0 show dots 3 \"Loading data\" blue"
            echo "  $0 show pong 5 \"Playing game\" bright_green"
            echo "  $0 run shark \"Downloading\" cyan sleep 10"
            echo ""
            echo "Colors: red, green, yellow, blue, magenta, cyan, white"
            echo "        bright_red, bright_green, bright_yellow, bright_blue,"
            echo "        bright_magenta, bright_cyan, bright_white"
            ;;
        *)
            echo "Unknown command: $1" >&2
            echo "Use '$0 help' for usage information" >&2
            exit 1
            ;;
    esac
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
