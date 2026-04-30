# Bro CLI

Personal AI assistant untuk terminal. Gratis, instant, dan mudah digunakan.

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
# Setup API Key
echo 'export OPENROUTER_API_KEY="sk-or-v1-xxxxx"' >> ~/.bashrc
source ~/.bash# Dapatkan gratis di https://openrouter.ai
```

## Penggunaan

```bash
bro "halo"

bro -m              # Pilih model
bro -r file.txt     # Baca & proses file
bro --stats         # Lihat usage

echo "pertanyaan" | bro  # Pipe support
bro --stream        # Streaming response
```

## Commands

| Command | Fungsi |
|---------|--------|
| `bro "text"` | Chat biasa |
| `-m` | Ganti model |
| `-n` | Chat baru |
| `-y` | Lihat riwayat |
| `-c` | Hapus riwayat |
| `-r <file>` | Baca file |
| `-w <file> <isi>` | Tulis file |
| `--config` | Lihat config |
| `--theme light/dark` | Ganti tema |
| `--stats` | Statistik usage |
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

## Lisensi

MIT