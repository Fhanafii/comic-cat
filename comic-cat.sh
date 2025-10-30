#!/bin/bash

# ───────────────────────────────
# comic-cat
# Version: 1.0.0
# Description: Fetch and view comics from KomikCast via terminal.
# Author: You 😎
# ──────────────────────────────

SOURCE="https://komikcast03.com"
TMP_DIR=""
VERSION="1.0.0"

# Clean up temp files
cleanup() {
  if [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]]; then
    echo "Cleaning up temporary files..."
    rm -rf "$TMP_DIR"
  fi
}
trap cleanup EXIT

# Help
show_help() {
  echo "comit-cat - Command Line Comic Reader"
  echo
  echo "Usage: comic-cat [options]"
  echo
  echo "Options:"
  echo "  -h, --help        Show this help message"
  echo "  -v, --version     Show version information"
  echo
  echo "Example:"
  echo "  comic-cat         # Launch interactive comic fetcher"
  echo
}


case "$1" in
  -v|--version)
    echo "comic-cat version $VERSION"
    exit 0
    ;;
  -h|--help)
    show_help
    exit 0
    ;;
esac

# Fetch all chapters
fetch_chapters() {
  local title="$1"
  local slug
  slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
  local comic_url="$SOURCE/komik/$slug/"

  echo

  local html
  html=$(curl -s -L -A "Mozilla/5.0" "$comic_url")

  if [ -z "$html" ]; then
    echo "Failed to fetch HTML. Check your connection or URL."
    exit 1
  fi

  local flat_html
  flat_html=$(echo "$html" | tr -d '\n' | tr -d '\r')

  local chapters
  chapters=$(echo "$flat_html" | grep -oP '<a class="chapter-link-item" href="[^"]+">Chapter[^<]+' |
    sed -E 's/.*href="([^"]+)">([^<]+)/\2|\1/')

  if [ -z "$chapters" ]; then
    echo "No chapters found for $title"
    exit 1
  fi

  echo "$chapters"
}

# Select a chapter
select_chapter() {
  local chapters="$1"

  local selected
  selected=$(echo "$chapters" | awk -F"|" '{print $1}' | fzf --reverse --prompt="Select Chapter: " --height=80% --border)

  if [ -z "$selected" ]; then
    echo "No chapter selected."
    exit 1
  fi

  local chapter_url
  chapter_url=$(echo "$chapters" | grep "$selected" | cut -d"|" -f2)

  echo "$selected|$chapter_url"
}

# Fetch chapter images
fetch_images() {
  local chapter_url="$1"
  echo
  echo "Fetching images from: $chapter_url"
  echo

  local chapter_html
  chapter_html=$(curl -s -L -A "Mozilla/5.0" "$chapter_url")

  if [ -z "$chapter_html" ]; then
    echo "Failed to fetch chapter page."
    exit 1
  fi

  local image_urls
  image_urls=$(echo "$chapter_html" | grep -oP '(https://[^"]+imgkc[^"]+\.jpg)' | sort -u)

  if [ -z "$image_urls" ]; then
    echo "No image URLs found in chapter."
    exit 1
  fi

  echo "$image_urls"
}

# Download all images
download_images() {
  local image_urls="$1"
  TMP_DIR=$(mktemp -d)

  echo "Downloading all pages in order..."
  local i=1

  while read -r img; do
    local page
    page=$(printf "%03d" "$i")
    curl -s -L -A "Mozilla/5.0" -e "$SOURCE" -o "${TMP_DIR}/${page}.jpg" "$img"
    ((i++))
  done <<< "$image_urls"

  echo "Download complete!"
}

# Open in external viewer
open_viewer() {
  echo "Opening images in viewer..."
  if command -v feh >/dev/null 2>&1; then
    feh "${TMP_DIR}"/*.jpg
  elif command -v eog >/dev/null 2>&1; then
    eog "${TMP_DIR}"/*.jpg
  else
    xdg-open "${TMP_DIR}"/*.jpg >/dev/null 2>&1
    read -p "Press Enter after closing the viewer..."
  fi
}

main() {
  read -p "Enter comic title: " title

  chapters=$(fetch_chapters "$title")
  selected_data=$(select_chapter "$chapters")

  selected_chapter=$(echo "$selected_data" | cut -d"|" -f1)
  chapter_url=$(echo "$selected_data" | cut -d"|" -f2)

  echo
  echo "Selected: $selected_chapter"
  echo

  image_urls=$(fetch_images "$chapter_url")
  download_images "$image_urls"
  open_viewer
  echo "Done! Temporary images deleted."
}

main