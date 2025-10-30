# comic-cat

A command-line tool to fetch and view comics directly in your terminal.

## Description

comic-cat is a simple Bash script that allows you to search for comics on KomikCast, select chapters interactively, and view them using image viewer. It's designed for comic enthusiasts who prefer a terminal-based experience.

## Features

- Automatic image downloading and temporary storage
- Support for multiple image viewers (feh, eog, or default system viewer)
- Clean temporary file management
- Version and help options

## Installation

1. Clone or download the repository:
   ```bash
   git clone https://github.com/Fhanafii/comic-cat.git
   cd comic-cat
   ```

2. Make the script executable:
   ```bash
   chmod +x comic-cat.sh
   ```

3. (Optional) Add to your PATH for global access:
   ```bash
   sudo cp comic-cat.sh /usr/local/bin/comic-cat
   ```

## Usage

Run the script without arguments to start the interactive mode:

```bash
./comic-cat.sh
```

Or if added to PATH:

```bash
comic-cat
```

### Options

- `-h, --help`: Display help message
- `-v, --version`: Display version information

### Example

1. Run the script:
   ```bash
   ./comic-cat.sh
   ```

2. Enter the comic title when prompted (e.g., "One Piece").

3. Select a chapter from the list using the fuzzy finder.

4. The script will download the images and open them in your image viewer.

5. Close the viewer when done; temporary files are automatically cleaned up.

## Dependencies

- `curl`: For fetching web content
- `fzf`: For interactive selection (install via package manager, e.g., `sudo apt install fzf`)
- Image viewer: `feh`, `eog`, or any viewer supported by `xdg-open`

Install dependencies on Ubuntu/Debian:
```bash
sudo apt update
sudo apt install curl fzf feh  # or eog
```

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.