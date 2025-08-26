# Spinner Gallery Website

This website displays all available CLI spinners in an interactive grid
format, making it easy to browse and select spinners for your projects.

## Features

- **Interactive Grid**: All 88 spinners displayed simultaneously with live
  animations at their authentic speeds
- **Dynamic Layout**: 4-column grid that adapts when searching/filtering
- **Search/Filter**: Real-time search to find specific spinners
- **Click to Copy**: Click any spinner to copy its name to clipboard
- **Theme Toggle**: Light/dark theme switcher with localStorage persistence
- **Responsive Design**: Works on desktop, tablet, and mobile devices
- **Live Animations**: Each spinner runs at its correct interval timing
- **Font Rendering Note**: Includes explanation why some spinners may appear
  different than in terminal

## Usage

### Quick Start

1. Use the Makefile target:
   ```bash
   make serve
   ```

2. Open your browser to: `http://localhost:8080`

### Manual Setup

1. Start a local web server:
   ```bash
   cd website
   python3 -m http.server 8080
   ```

2. Open your browser to: `http://localhost:8080`

### Alternative Servers

```bash
# Node.js (if you have npx)
npx serve .

# PHP
php -S localhost:8000

# Python 2
python -m SimpleHTTPServer 8080
```

## File Structure

- `index.html` - Main website file (self-contained with CSS/JS)
- `README.md` - This documentation
- `spinners.json` - Symlinked from parent directory (auto-created by `make
  serve`)

The website loads spinner data from a symlinked `spinners.json` file that
points to `../spinners.json`.

## Browser Compatibility

- Chrome/Edge 63+
- Firefox 53+
- Safari 13.1+
- iOS Safari 13.4+
- Any modern browser with JavaScript enabled
