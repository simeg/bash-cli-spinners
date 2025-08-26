#!/bin/bash

# Basic test suite for bash-cli-spinners
# Tests core functionality, dependencies, and data integrity

# shellcheck disable=SC2034  # Disable unused variable warnings for color codes
# Note: Not using 'set -e' to allow tests to continue even if some fail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPINNER_SCRIPT="$SCRIPT_DIR/spinner.sh"
SPINNERS_JSON="$SCRIPT_DIR/spinners.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test result tracking
test_pass() {
    ((TESTS_RUN++))
    ((TESTS_PASSED++))
    echo -e "${GREEN}✓${NC} $1"
}

test_fail() {
    ((TESTS_RUN++))
    ((TESTS_FAILED++))
    echo -e "${RED}✗${NC} $1"
    echo "🚨 TEST FAILURE DETAILS:"
    echo "  - Failed test: $1"
    echo "  - Script: $0"
    echo "  - Working directory: $(pwd)"
    echo "  - Files in current directory:"
    ls -la || echo "    Could not list files"
    echo
}

test_skip() {
    echo -e "${YELLOW}⚠${NC} $1 (SKIPPED)"
}

echo "🧪 Running bash-cli-spinners test suite..."
echo

# Test 1: Check if required files exist
echo "📁 File Existence Tests"
if [[ -f "$SPINNER_SCRIPT" ]]; then
    test_pass "spinner.sh exists"
else
    test_fail "spinner.sh not found at $SPINNER_SCRIPT"
fi

if [[ -f "$SPINNERS_JSON" ]]; then
    test_pass "spinners.json exists"
else
    test_fail "spinners.json not found at $SPINNERS_JSON"
fi

# Test 2: Check if spinner.sh is executable
if [[ -x "$SPINNER_SCRIPT" ]]; then
    test_pass "spinner.sh is executable"
else
    test_fail "spinner.sh is not executable (run: chmod +x spinner.sh)"
fi

echo

# Test 3: Check dependencies
echo "🔧 Dependency Tests"
if command -v jq >/dev/null 2>&1; then
    test_pass "jq is installed"
else
    test_fail "jq is not installed (required for JSON parsing)"
fi

if command -v bc >/dev/null 2>&1; then
    test_pass "bc is installed"
else
    test_fail "bc is not installed (required for timing calculations)"
fi

echo

# Test 4: JSON validity and structure
echo "📋 JSON Data Tests"
if command -v jq >/dev/null 2>&1 && [[ -f "$SPINNERS_JSON" ]]; then
    if jq empty "$SPINNERS_JSON" >/dev/null 2>&1; then
        test_pass "spinners.json is valid JSON"
        
        # Count spinners
        spinner_count=$(jq 'keys | length' "$SPINNERS_JSON" 2>/dev/null || echo "0")
        if [[ $spinner_count -gt 0 ]]; then
            test_pass "spinners.json contains $spinner_count spinners"
        else
            test_fail "spinners.json contains no spinners"
        fi
        
        # Test a few specific spinners exist
        for spinner in "dots" "line" "pong"; do
            if jq -e ".\"$spinner\"" "$SPINNERS_JSON" >/dev/null 2>&1; then
                test_pass "Spinner '$spinner' exists in database"
            else
                test_fail "Spinner '$spinner' missing from database"
            fi
        done
        
        # Test spinner data structure
        if jq -e '.dots.interval' "$SPINNERS_JSON" >/dev/null 2>&1 && \
           jq -e '.dots.frames[]' "$SPINNERS_JSON" >/dev/null 2>&1; then
            test_pass "Spinner data has correct structure (interval + frames)"
        else
            test_fail "Spinner data structure is invalid"
        fi
        
    else
        test_fail "spinners.json is not valid JSON"
    fi
else
    test_skip "JSON validation (jq not available or file missing)"
fi

echo

# Test 5: Basic script functionality
echo "⚡ Functionality Tests"
if [[ -x "$SPINNER_SCRIPT" ]]; then
    # Test help command
    if "$SPINNER_SCRIPT" help >/dev/null 2>&1; then
        test_pass "Help command works"
    else
        test_fail "Help command failed"
    fi
    
    # Test list command
    if "$SPINNER_SCRIPT" list >/dev/null 2>&1; then
        test_pass "List command works"
    else
        test_fail "List command failed"
    fi
    
    # Test invalid spinner handling
    if ! "$SPINNER_SCRIPT" show nonexistent_spinner 1 >/dev/null 2>&1; then
        test_pass "Invalid spinner name properly rejected"
    else
        test_fail "Invalid spinner name was accepted"
    fi
    
    # Test sourcing (if dependencies available)
    if command -v jq >/dev/null 2>&1 && command -v bc >/dev/null 2>&1; then
        # shellcheck source=spinner.sh disable=SC1091
        if source "$SPINNER_SCRIPT" 2>/dev/null && \
           declare -f show_spinner >/dev/null 2>&1; then
            test_pass "Script can be sourced and functions are available"
        else
            test_fail "Script sourcing failed or functions not available"
        fi
    else
        test_skip "Function sourcing test (dependencies missing)"
    fi
    
else
    test_skip "Functionality tests (spinner.sh not executable)"
fi

echo

# Test 6: Performance check (basic)
echo "🚀 Performance Tests"
if [[ -x "$SPINNER_SCRIPT" ]] && command -v jq >/dev/null 2>&1; then
    # Time the list command
    start_time=$(date +%s%N)
    "$SPINNER_SCRIPT" list >/dev/null 2>&1
    end_time=$(date +%s%N)
    duration=$(( (end_time - start_time) / 1000000 )) # Convert to milliseconds
    
    if [[ $duration -lt 1000 ]]; then # Less than 1 second
        test_pass "List command completes quickly (${duration}ms)"
    else
        test_fail "List command is slow (${duration}ms)"
    fi
else
    test_skip "Performance tests (dependencies missing)"
fi

echo

# Test Summary
echo "📊 Test Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Tests run: $TESTS_RUN"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
else
    echo -e "Failed: $TESTS_FAILED"
fi

echo

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed.${NC}"
    echo "Please check the failed tests above and resolve any issues."
    echo
    echo "🔍 Environment Information:"
    echo "  - Working directory: $(pwd)"
    echo "  - Script location: $0"
    echo "  - Spinner script: $SPINNER_SCRIPT"
    echo "  - Spinners JSON: $SPINNERS_JSON"
    echo "  - Available files:"
    ls -la 2>/dev/null || echo "    Could not list files"
    echo
    echo "🔧 Dependencies Check:"
    command -v jq >/dev/null && echo "  - jq: $(which jq)" || echo "  - jq: NOT FOUND"
    command -v bc >/dev/null && echo "  - bc: $(which bc)" || echo "  - bc: NOT FOUND"
    exit 1
fi