# Bash CLI Spinners Makefile

.PHONY: serve demo help

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
	@./demo.sh

# Show available make targets
help:
	@echo "Available targets:"
	@echo "  serve  - Start the spinner gallery web server"
	@echo "  demo   - Run the comprehensive spinner demo"
	@echo "  help   - Show this help message"