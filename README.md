# Bro CLI

Personal AI assistant for your terminal.

## Install

```bash
mkdir -p ~/.local/bin
cp bro ~/.local/bin/
chmod +x ~/.local/bin/bro
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Setup

```bash
# Groq (default - faster)
echo 'export GROQ_API_KEY="gsk_xxxxx"' >> ~/.bashrc
source ~/.bashrc

# Get free key: https://console.groq.com
```

## Usage

```bash
bro "hello"

bro -m              # Select model
bro --stats         # View usage stats

echo "question" | bro  # Pipe support
```

## Commands

| Command | Description |
|---------|-------------|
| `-m, --model` | Switch model |
| `-n` | New chat |
| `-y` | View history |
| `-c` | Clear history |
| `-r <file>` | Read file |
| `-w <file> <content>` | Write file |
| `-t, --theme` | Light/dark |
| `--config` | Show config |
| `--stats` | Usage stats |
| `--help` | Help |

## Models

**Groq:**
- llama-3.3-70b-versatile (default)
- llama-3.1-8b-instant

## Features

- Typewriter animation
- Streaming response
- Session history
- File operations
- Pipe support

## Uninstall

```bash
rm ~/.local/bin/bro ~/.config/bro -rf
```

## License

MIT