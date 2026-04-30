# Bro CLI

Personal AI assistant for your terminal. Free, instant, and easy to use.

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
# Get free API key at https://openrouter.ai
echo 'export OPENROUTER_API_KEY="sk-or-v1-xxxxx"' >> ~/.bashrc
source ~/.bashrc
```

## Usage

```bash
bro "hello"

bro -m              # Select model
bro -r file.txt     # Read & process file
bro --stats         # View usage stats

echo "question" | bro  # Pipe support
bro --stream        # Streaming response
```

## Commands

| Command | Description |
|---------|-------------|
| `bro "text"` | Regular chat |
| `-m` | Change model |
| `-n` | New chat |
| `-y` | View history |
| `-c` | Clear history |
| `-r <file>` | Read file |
| `-w <file> <content>` | Write file |
| `--config` | Show config |
| `--theme light/dark` | Change theme |
| `--stats` | Usage stats |
| `--export <file>` | Export chat |
| `--import <file>` | Import chat |
| `--help` | Help |

## Available Models

- google/gemini-2.5-flash
- meta-llama/llama-3.3-70b-instruct
- deepseek/deepseek-chat
- qwen/qwen-2.5-72b-instruct
- openai/gpt-4o
- mistralai/mixtral-8x7b-instruct

## Uninstall

```bash
rm ~/.local/bin/bro ~/.config/bro -rf
```

## License

MIT