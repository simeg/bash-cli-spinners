# Bash CLI Spinners Makefile

.PHONY: serve demo help test lint clean install uninstall check

# Show available make targets (default)
help:
	@echo "🌀 Bash CLI Spinners - Available targets:"
	@echo ""
	@echo "  🌐 serve      - Start the spinner gallery web server"
	@echo "  🎬 demo       - Run the comprehensive spinner demo"
	@echo "  🧪 test       - Run the test suite"
	@echo "  🔍 lint       - Run shellcheck linting"
	@echo "  📦 install    - Install system-wide"
	@echo "  🗑️  uninstall  - Remove system installation"
	@echo "  🧹 clean      - Clean temporary files"
	@echo "  ✅ check      - Run all checks (lint + test)"
	@echo "  ❓ help       - Show this help message"

# Start the spinner gallery web server
serve:
	@echo "🌀 Starting Spinner Gallery Server..."
	@echo "📂 Serving from: website/"
	@echo "🔗 Creating symlink to spinners.json..."
	@ln -sf ../spinners.json website/spinners.json
	@echo "🌐 URL: http://localhost:8080"
	@echo "📝 Press Ctrl+C to stop the server"
	@echo ""
	@cd website && python3 -m http.server 8080

# Run the comprehensive spinner demo
demo:
	@echo "🎬 Running comprehensive spinner demo..."
	@chmod +x demo.sh
	@./demo.sh

# Run the test suite
test:
	@echo "🧪 Running test suite..."
	@chmod +x test.sh
	@./test.sh

# Run linting with shellcheck
lint:
	@echo "🔍 Running shellcheck..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck spinner.sh test.sh demo.sh; \
		echo "✅ Linting passed!"; \
	else \
		echo "❌ shellcheck not found. Install with:"; \
		echo "  macOS: brew install shellcheck"; \
		echo "  Ubuntu: sudo apt install shellcheck"; \
		exit 1; \
	fi

# Install system-wide
install:
	@echo "📦 Installing bash-cli-spinners system-wide..."
	@sudo cp spinner.sh /usr/local/bin/spinner
	@sudo mkdir -p /usr/local/share/bash-cli-spinners
	@sudo cp spinners.json /usr/local/share/bash-cli-spinners/
	@sudo sed -i.bak 's|SCRIPT_DIR.*|SPINNERS_JSON="/usr/local/share/bash-cli-spinners/spinners.json"|' /usr/local/bin/spinner
	@echo "✅ Installed! You can now use 'spinner' command globally"
	@echo "🧪 Test with: spinner list"

# Uninstall system installation
uninstall:
	@echo "🗑️ Removing system installation..."
	@sudo rm -f /usr/local/bin/spinner
	@sudo rm -rf /usr/local/share/bash-cli-spinners
	@echo "✅ Uninstalled successfully"

# Clean temporary files
clean:
	@echo "🧹 Cleaning temporary files..."
	@rm -f website/spinners.json
	@echo "✅ Cleaned"

# Run all checks before commit
check: lint test
	@echo "✅ All checks passed! Ready to commit."
