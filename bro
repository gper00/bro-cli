#!/usr/bin/env node

import fs from 'fs';
import path from 'path';
import os from 'os';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Konfigurasi
const CONFIG_DIR = path.join(os.homedir(), '.config', 'bro');
const CONFIG_FILE = path.join(CONFIG_DIR, 'config.json');
const SESSION_FILE = path.join(CONFIG_DIR, 'session.json');
const DEFAULT_MODEL = 'google/gemini-2.5-flash';
const DEFAULT_SYSTEM_PROMPT = 'Kamu adalah asisten AI yang helpful. Jawab dalam bahasa yang sama dengan user.';

// Theme definitions
const THEMES = {
    light: {
        TEAL: '\x1b[38;5;24m',
        BROWN: '\x1b[38;5;130m',
        FOREST: '\x1b[38;5;28m',
        RED: '\x1b[38;5;160m',
        NAVY: '\x1b[38;5;19m',
        OCHRE: '\x1b[38;5;136m',
        PLUM: '\x1b[38;5;55m',
        DGRAY: '\x1b[38;5;240m',
        INK: '\x1b[38;5;235m',
        BLACK: '\x1b[38;5;16m',
        MGRAY: '\x1b[38;5;246m',
    },
    dark: {
        TEAL: '\x1b[38;5;45m',
        BROWN: '\x1b[38;5;208m',
        FOREST: '\x1b[38;5;46m',
        RED: '\x1b[38;5;196m',
        NAVY: '\x1b[38;5;33m',
        OCHRE: '\x1b[38;5;220m',
        PLUM: '\x1b[38;5;129m',
        DGRAY: '\x1b[38;5;250m',
        INK: '\x1b[38;5;255m',
        BLACK: '\x1b[38;5;255m',
        MGRAY: '\x1b[38;5;244m',
    }
};

// Active theme (default light)
let theme = THEMES.light;
const MODELS = [
    { id: 'google/gemini-2.5-flash', name: 'Gemini 2.5 Flash', desc: 'Terbaik & terbaru dari Google' },
    { id: 'google/gemini-2.0-flash-001', name: 'Gemini 2.0 Flash', desc: 'Cepat & responsif' },
    { id: 'meta-llama/llama-3.3-70b-instruct', name: 'Llama 3.3 70B', desc: 'Meta AI, konteks panjang' },
    { id: 'deepseek/deepseek-chat', name: 'DeepSeek Chat', desc: 'Open source, efisien' },
    { id: 'qwen/qwen-2.5-72b-instruct', name: 'Qwen 2.5 72B', desc: 'Alibaba, cepat' },
    { id: 'anthropic/claude-3.5-sonnet', name: 'Claude 3.5 Sonnet', desc: 'Anthropic, reasoning kuat' },
    { id: 'openai/gpt-4o', name: 'GPT-4o', desc: 'OpenAI, paling smart' },
    { id: 'mistralai/mixtral-8x7b-instruct', name: 'Mixtral 8x7B', desc: 'Mistral, konteks 32K' },
];

// Warna - 256 color palette (Light Theme)
const R = '\x1b[0m';
const BOLD = '\x1b[1m';
const DIM = '\x1b[2m';
const ITALIC = '\x1b[3m';
const UL = '\x1b[4m';

const TEAL = '\x1b[38;5;24m';      // Biru teal → border & aksen utama
const BROWN = '\x1b[38;5;130m';    // Oranye coklat → label user
const FOREST = '\x1b[38;5;28m';    // Hijau tua → label bro / sukses
const RED = '\x1b[38;5;160m';      // Merah gelap → error
const NAVY = '\x1b[38;5;19m';      // Navy → flags
const OCHRE = '\x1b[38;5;136m';    // Kuning tua → kode inline
const PLUM = '\x1b[38;5;55m';      // Ungu tua → heading
const DGRAY = '\x1b[38;5;240m';    // Abu gelap → teks sekunder
const INK = '\x1b[38;5;235m';      // Hampir hitam → teks utama
const BLACK = '\x1b[38;5;16m';     // Hitam → judul bold
const MGRAY = '\x1b[38;5;246m';    // Abu medium → border box
const TEAL_BG = '\x1b[48;5;24m';
const YELLOW = '\x1b[38;5;220m';     // Kuning terang → loading/warning

// Helper functions
function p(...args) { console.log(...args); }

function tw() {
    try {
        const cols = process.stdout.columns || 80;
        return cols < 40 ? 80 : cols;
    } catch {
        return 80;
    }
}

function rpt(n, ch) {
    return ch.repeat(n);
}

function box(title, subtitle = '') {
    const w = tw();
    p(`\n  ${BLACK}${BOLD}${title}${R}`);
    if (subtitle) {
        p(`  ${DGRAY}${subtitle}${R}`);
    }
    p();
}

function userBubble(text) {
    // Simple - just show label, no border, no repeat text
    p(`\n  ${BROWN}${BOLD}👤 Kamu${R}`);
}

function aiBubble(text) {
    const w = tw();
    const maxC = Math.max(w - 4, 50);
    
    const lines = parseMarkdown(text, maxC, true);
    
    p(`\n${TEAL}✦ Bro${R}\n`);
    
    let inCode = false;
    let prevEmpty = true;
    
    lines.forEach(line => {
        if (line.startsWith('```')) {
            if (!inCode) {
                inCode = true;
                const lang = line.slice(3).trim() || 'code';
                p(`${DGRAY}▼ ${lang}${R}`);
            } else {
                inCode = false;
                prevEmpty = true;
            }
            return;
        }
        
        if (inCode) {
            p(`${OCHRE}${line}${R}`);
            return;
        }
        
        if ((line.startsWith('▸') || line.startsWith('◈') || line.startsWith('★')) && !prevEmpty) {
            p('');
        }
        
        if (line.trim()) {
            p(`${INK}${line}${R}`);
            prevEmpty = false;
        }
    });
}

function wrapText(text, maxWidth) {
    const words = text.split(' ');
    const lines = [];
    let current = '';
    
    words.forEach(word => {
        if ((current + ' ' + word).trim().length <= maxWidth) {
            current = (current + ' ' + word).trim();
        } else {
            if (current) lines.push(current);
            current = word;
        }
    });
    if (current) lines.push(current);
    return lines;
}

function parseMarkdown(text, maxWidth, preserveCodeIndent = false) {
    const result = [];
    const lines = text.split('\n');
    let inCodeBlock = false;
    
    lines.forEach(line => {
        // Code block start/end
        if (line.startsWith('```')) {
            inCodeBlock = !inCodeBlock;
            result.push(line);
            return;
        }
        
        // Inside code block - preserve indentation
        if (inCodeBlock) {
            result.push(line);
            return;
        }
        
        // Empty line
        if (!line.trim()) {
            result.push('');
            return;
        }
        
        // Headings
        if (line.startsWith('### ')) {
            result.push(`${PLUM}${BOLD}▸ ${line.slice(4)}${R}`);
            return;
        }
        if (line.startsWith('## ')) {
            result.push(`${NAVY}${BOLD}◈ ${line.slice(3)}${R}`);
            return;
        }
        if (line.startsWith('# ')) {
            result.push(`${BROWN}${BOLD}★ ${line.slice(2)}${R}`);
            return;
        }
        
        // List
        if (line.match(/^(\s*[-•]|\s*\d+\.)\s/)) {
            line = line.replace(/^(\s*)([-•]|\d+\.)\s/, `$1${TEAL}●${R} `);
            result.push(line);
            return;
        }
        
        // Bold
        line = line.replace(/\*\*([^*]+)\*\*/g, `${BOLD}$1${R}`);
        // Inline code
        line = line.replace(/`([^`]+)`/g, `${OCHRE}$1${R}`);
        
        // Wrap long lines
        const wrapped = wrapText(line, maxWidth);
        wrapped.forEach(l => result.push(l));
    });
    
    return result;
}

function showSpinner(pid) {
    let dots = 0;
    const interval = setInterval(() => {
        if (process.kill(pid, 0)) {
            dots = (dots + 1) % 4;
            process.stdout.write(`\r${TEAL}bro lagi mikir${'.'.repeat(dots)}`);
        } else {
            clearInterval(interval);
            process.stdout.write('\r' + ' '.repeat(20) + '\r');
        }
    }, 400);
    return interval;
}

function ensureConfig() {
    if (!fs.existsSync(CONFIG_DIR)) {
        fs.mkdirSync(CONFIG_DIR, { recursive: true });
    }
    if (!fs.existsSync(CONFIG_FILE)) {
        fs.writeFileSync(CONFIG_FILE, JSON.stringify({
            model: DEFAULT_MODEL,
            theme: 'light',
            systemPrompt: DEFAULT_SYSTEM_PROMPT
        }, null, 2));
    }
    if (!fs.existsSync(SESSION_FILE)) {
        fs.writeFileSync(SESSION_FILE, JSON.stringify([], null, 2));
    }
}

function loadConfig() {
    ensureConfig();
    const config = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
    // Load theme
    if (config.theme && THEMES[config.theme]) {
        theme = THEMES[config.theme];
    }
    return config;
}

function saveConfig(config) {
    fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2));
}

function loadSession() {
    ensureConfig();
    return JSON.parse(fs.readFileSync(SESSION_FILE, 'utf8'));
}

function saveSession(session) {
    fs.writeFileSync(SESSION_FILE, JSON.stringify(session, null, 2));
}

function getApiKey() {
    const key = process.env.OPENROUTER_API_KEY;
    if (!key) {
        p(`\n  ${RED}${BOLD}✗${R}  OPENROUTER_API_KEY belum diset di .bashrc`);
        p(`  ${DGRAY}Cara set:${R} echo 'export OPENROUTER_API_KEY="你的key"' >> ~/.bashrc`);
        p(`  ${DGRAY}Lalu:${R} source ~/.bashrc\n`);
        process.exit(1);
    }
    return key;
}

async function checkOnline() {
    try {
        const { exec } = await import('child_process');
        return new Promise((resolve) => {
            exec('curl -sf --max-time 5 https://openrouter.ai', (err) => {
                resolve(!err);
            });
        });
    } catch {
        return false;
    }
}

const ERROR_HELP = {
    '401': 'API key invalid atau expired. Setup ulang: bro --setup',
    '403': 'Akses ditolak. Cek API key atau quota.',
    '429': 'Rate limit. Tunggu 1 menit, atau gunakan model lain: bro -m',
    '500': 'Server error. Coba lagi nanti.',
    '502': 'Server error. Coba lagi.',
    '503': 'Server overload. Tunggu sebentar.',
    'NETWORK': 'Cek koneksi internet, atau VPN.',
    'TIMEOUT': 'Request timeout. Coba lagi atau gunakan model lebih ringan.',
};

function showError(type, message, help = '') {
    p(`\n  ${RED}${BOLD}✗${R}  ${BOLD}${type}:${R} ${message}`);
    if (help) {
        p(`  ${DGRAY}→ ${help}${R}`);
    }
    p();
}

function validateInput(input) {
    const trimmed = input.trim();
    if (!trimmed) {
        showError('Input Error', 'Pertanyaan tidak boleh kosong.');
        process.exit(1);
    }
    if (trimmed.length > 10000) {
        showError('Input Error', 'Pertanyaan terlalu panjang (max 10.000 karakter).', 'Pertanyaanmu dipotong.');
        return trimmed.substring(0, 10000);
    }
    return trimmed;
}

let currentCurl = null;
function setupSignalHandler() {
    process.on('SIGINT', () => {
        if (currentCurl) {
            try {
                process.kill(currentCurl.pid, 'SIGTERM');
            } catch {}
        }
        p(`\n  ${YELLOW}⚠${R}  Request dibatalkan.\n`);
        process.exit(0);
    });
}

// Pipe support - check if there's input from pipe
function checkPipeInput() {
    if (!process.stdin.isTTY) {
        let chunks = [];
        return new Promise((resolve) => {
            process.stdin.on('data', (chunk) => chunks.push(chunk));
            process.stdin.on('end', () => {
                const input = Buffer.concat(chunks).toString().trim();
                resolve(input);
            });
            process.stdin.on('error', () => resolve(''));
            // Timeout for pipe check
            setTimeout(() => resolve(''), 1000);
        });
    }
    return Promise.resolve('');
}

// Interactive mode - multi-line input
async function interactiveMode() {
    const readline = await import('readline');
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
        terminal: true
    });
    
    p(`\n  ${TEAL}${BOLD}📝 Interactive Mode${R}`);
    p(`  ${DGRAY}Ketik pertanyaan panjang, ENTER untuk baris baru.`);
    p(`  ${DGRAY}Ctrl+D atau ketik /done untuk selesai.${R}\n`);
    
    let lines = [];
    let prompt = `  ${BROWN}›${R} `;
    
    for await (const line of rl) {
        if (line.trim() === '/done' || line.trim() === '\\\\d') {
            break;
        }
        lines.push(line);
    }
    rl.close();
    
    const query = lines.join('\n').trim();
    if (!query) {
        p(`  ${DGRAY}Tidak ada input.${R}\n`);
        return;
    }
    
    await cmdChat(query);
}

// Streaming response
async function cmdChatStreaming(query) {
    const apiKey = getApiKey();
    const config = loadConfig();
    const session = loadSession();
    
    query = validateInput(query);
    session.push({ role: 'user', content: query });
    userBubble(query);
    
    const online = await checkOnline();
    if (!online) {
        showError('Offline', 'Tidak ada koneksi internet.', ERROR_HELP['NETWORK']);
        process.exit(1);
    }
    
    const { spawn } = await import('child_process');
    const curl = spawn('curl', [
        '-s', '--no-buffer', '--max-time', '60',
        '-X', 'POST', 'https://openrouter.ai/api/v1/chat/completions',
        '-H', `Authorization: Bearer ${apiKey}`,
        '-H', 'Content-Type: application/json',
        '-H', 'HTTP-Referer: https://localhost',
        '-H', 'X-Title: Bro CLI',
        '-d', JSON.stringify({
            model: config.model,
            messages: session,
            max_tokens: 2048,
            stream: true
        })
    ]);
    
    currentCurl = curl;
    p(`\n  ${TEAL}✦ Bro:${R} `);
    
    let fullResponse = '';
    let buffer = '';
    
    curl.stdout.on('data', (data) => {
        buffer += data.toString();
        
        // Parse SSE (Server-Sent Events)
        const lines = buffer.split('\n');
        buffer = lines.pop();
        
        lines.forEach(line => {
            if (line.startsWith('data: ')) {
                const json = line.slice(6);
                if (json === '[DONE]') return;
                try {
                    const parsed = JSON.parse(json);
                    const content = parsed.choices?.[0]?.delta?.content;
                    if (content) {
                        fullResponse += content;
                        process.stdout.write(`${INK}${content}${R}`);
                    }
                } catch {}
            }
        });
    });
    
    return new Promise((resolve, reject) => {
        curl.on('close', (code) => {
            currentCurl = null;
            p('\n');
            
            const tokens = Math.ceil(fullResponse.length / 4);
            p(`\n${MGRAY}────────────────────────────────${R}`);
    p(`${MGRAY}⚡  ${tokens} token${R}  ·  ${DGRAY}${config.model}${R}`);
            
            session.push({ role: 'assistant', content: fullResponse });
            if (session.length > 40) {
                session.splice(0, session.length - 40);
            }
            saveSession(session);
            
            resolve();
        });
    });
}

function expandPath(p) {
    if (p.startsWith('~')) {
        return p.replace('~', os.homedir());
    }
    return p;
}

// CLI parsing
const args = process.argv.slice(2);
const command = args[0] || '';

function showHelp() {
    box("⚡  BRO CLI", "OpenRouter AI");
    
    p(`  ${INK}${BOLD}USAGE${R}`);
    p(`  ${TEAL}bro${R} ${INK}"pertanyaan kamu"${R}`);
    p(`  ${TEAL}bro${R} ${INK}-m "ganti model dan chat"${R}`);
    p();
    p(`  ${INK}${BOLD}FLAGS${R}`);
    
    const flags = [
        ['--help,-h', 'Tampilkan bantuan ini'],
        ['--new,-n', 'Mulai percakapan baru (hapus konteks)'],
        ['--history,-y', 'Lihat riwayat percakapan'],
        ['--clear,-c', 'Hapus semua riwayat'],
        ['--model,-m', 'Pilih/ganti model AI'],
        ['--read,-r', 'Baca file dan proses dengan AI'],
        ['--write,-w', 'Tulis ke file'],
        ['--append,-a', 'Tambah ke file'],
        ['--theme,-t', 'Ganti theme (light/dark)'],
        ['--config', 'Lihat/edit konfigurasi'],
        ['--stream,-s', 'Streaming response (real-time)'],
        ['--interactive,-i', 'Mode interaktif (multi-line)'],
        ['--export', 'Export session ke file JSON'],
        ['--import', 'Import session dari file JSON'],
        ['--stats', 'Lihat total penggunaan token'],
        ['--verbose,-v', 'Mode debug (tampilkan detail)'],
        ['--reset', 'Reset semua (config + session)'],
    ];
    
    flags.forEach(([f, d]) => {
        const pad = 12 - f.length;
        p(`  ${TEAL}${BOLD}${f}${rpt(pad, ' ')}${R} ${DGRAY}${d}${R}`);
    });
    
    p();
    p(`  ${INK}${BOLD}CONTOH${R}`);
    const ex = [
        'bro "halo bro!"',
        'bro -m              # pilih model baru',
        'bro -r ~/file.txt  # baca file',
        'bro -w ~/notes.txt "isi"  # tulis file',
        'bro -n             # mulai obrolan baru',
    ];
    ex.forEach(e => p(`  ${DGRAY}${e}${R}`));
    
    p(`\n  ${INK}${BOLD}KONFIG${R}  ${DGRAY}~/.config/bro/${R}\n`);
}

function showModels() {
    const config = loadConfig();
    box("🤖  Pilih Model AI", config.model);
    
    MODELS.forEach((m, i) => {
        const marker = m.id === config.model ? `  ${FOREST}${BOLD}← aktif${R}` : '';
        p(`  ${TEAL}${BOLD}${i + 1}.${R}  ${m.id}`);
        p(`     ${DGRAY}${m.name} - ${m.desc}${marker}`);
        p();
    });
    
    p(`  ${DGRAY}Pilih nomor (1-${MODELS.length}):${R}`);
}

async function selectModel() {
    showModels();
    const readline = await import('readline').then(m => m.createInterface({
        input: process.stdin,
        output: process.stdout
    }));
    
    return new Promise(resolve => {
        readline.question('', async (answer) => {
            readline.close();
            const idx = parseInt(answer) - 1;
            if (idx >= 0 && idx < MODELS.length) {
                const config = loadConfig();
                config.model = MODELS[idx].id;
                saveConfig(config);
                p(`\n  ${FOREST}${BOLD}✓${R} Model diubah ke: ${MODELS[idx].name}\n`);
            } else {
                p(`\n  ${DGRAY}Dibatalkan.${R}\n`);
            }
        });
    });
}

function cmdHistory() {
    const session = loadSession();
    box("📜  Riwayat Percakapan", `${Math.floor(session.length / 2)} pesan`);
    
    if (session.length === 0) {
        p(`  ${DGRAY}Belum ada percakapan.${R}\n`);
        return;
    }
    
    const w = tw();
    session.forEach((msg) => {
        if (msg.role === 'user') {
            p(`  ${BROWN}${BOLD}👤 Kamu:${R}`);
            p(`  ${INK}${msg.content.substring(0, 150)}${msg.content.length > 150 ? '...' : ''}`);
        } else {
            p(`  ${TEAL}${BOLD}✦ Bro:${R}`);
            p(`  ${DGRAY}${msg.content.substring(0, 150)}${msg.content.length > 150 ? '...' : ''}`);
        }
        p(`  ${MGRAY}${DIM}${rpt(w - 4, '─')}${R}`);
    });
    p();
}

function cmdClear() {
    p(`  ${DGRAY}⚠${R}  Hapus semua history sesi ini? (y/n): `);
}

function cmdNew() {
    saveSession([]);
    p(`\n  ${FOREST}${BOLD}✓${R}  Sesi baru dimulai.\n`);
}

function cmdStats() {
    const session = loadSession();
    const config = loadConfig();
    
    let userMsgs = 0, aiMsgs = 0, totalTokens = 0;
    session.forEach(msg => {
        if (msg.role === 'user') userMsgs++;
        else if (msg.role === 'assistant') {
            aiMsgs++;
            totalTokens += Math.ceil((msg.content || '').length / 4);
        }
    });
    
    box("📊 Statistik", "Lifetime usage");
    
    p(`  ${INK}${BOLD}Total Pesan:${R}    ${userMsgs + aiMsgs} (${userMsgs} user, ${aiMsgs} AI)`);
    p(`  ${INK}${BOLD}Total Token:${R}   ~${totalTokens} (estimasi)`);
    p(`  ${INK}${BOLD}Model:${R}         ${config.model}`);
    p(`  ${INK}${BOLD}Theme:${R}          ${config.theme || 'light'}`);
    p(`  ${INK}${BOLD}Session:${R}        ${Math.floor(session.length / 2)} percakapan`);
    p();
}

function cmdExport(filePath) {
    const fullPath = expandPath(filePath || 'bro-session.json');
    const config = loadConfig();
    const session = loadSession();
    
    const exportData = {
        version: '1.0',
        exported: new Date().toISOString(),
        config: { model: config.model, theme: config.theme },
        session: session
    };
    
    fs.writeFileSync(fullPath, JSON.stringify(exportData, null, 2));
    p(`  ${FOREST}${BOLD}✓${R}  Session diexport ke: ${fullPath}`);
    p(`  ${DGRAY}  ${session.length / 2} pesan${R}\n`);
}

function cmdImport(filePath) {
    if (!filePath) {
        showError('Usage', 'bro --import <file.json>');
        process.exit(1);
    }
    
    const fullPath = expandPath(filePath);
    if (!fs.existsSync(fullPath)) {
        showError('File Not Found', fullPath);
        process.exit(1);
    }
    
    try {
        const importData = JSON.parse(fs.readFileSync(fullPath, 'utf8'));
        
        if (importData.session) {
            saveSession(importData.session);
            p(`  ${FOREST}${BOLD}✓${R}  Session diimport dari: ${filePath}`);
            p(`  ${DGRAY}  ${importData.session.length / 2} pesan${R}\n`);
        } else {
            showError('Invalid Format', 'File bukan session bro yang valid.');
            process.exit(1);
        }
    } catch (e) {
        showError('Parse Error', 'Gagal baca file: ' + e.message);
        process.exit(1);
    }
}

function cmdReset() {
    p(`  ${RED}${BOLD}⚠${R}  Ini akan menghapus SEMUA config dan session. Yakin? (y/n): `);
}

function cmdRead(filePath, prompt = 'Jelaskan isi file ini') {
    const fullPath = expandPath(filePath);
    if (!fs.existsSync(fullPath)) {
        p(`  ${RED}${BOLD}✗${R}  File tidak ditemukan: ${filePath}`);
        process.exit(1);
    }
    const content = fs.readFileSync(fullPath, 'utf8');
    return `${prompt}\n\nBerikut isi filenya:\n\`\`\`\n${content}\n\`\`\``;
}

function cmdWrite(filePath, content) {
    const fullPath = expandPath(filePath);
    const dir = path.dirname(fullPath);
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(fullPath, content);
    p(`  ${FOREST}${BOLD}✓${R}  File ditulis: ${filePath}\n`);
}

function cmdAppend(filePath, content) {
    const fullPath = expandPath(filePath);
    const dir = path.dirname(fullPath);
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
    fs.appendFileSync(fullPath, content);
    p(`  ${FOREST}${BOLD}✓${R}  Ditambahkan ke: ${filePath}\n`);
}

function cmdConfig() {
    const config = loadConfig();
    box("⚙️  Konfigurasi", "~/.config/bro/config.json");
    
    p(`  ${INK}${BOLD}Model:${R}     ${config.model}`);
    p(`  ${INK}${BOLD}Theme:${R}      ${config.theme || 'light'}`);
    p(`  ${INK}${BOLD}System:${R}    ${(config.systemPrompt || DEFAULT_SYSTEM_PROMPT).substring(0, 50)}...`);
    p(`  ${INK}${BOLD}Session:${R}   ${Math.floor(loadSession().length / 2)} pesan`);
    p();
    p(`  ${DGRAY}Edit manual: nano ~/.config/bro/config.json${R}`);
    p();
}

function cmdTheme(newTheme) {
    if (!newTheme || !THEMES[newTheme]) {
        p(`\n  ${DGRAY}Usage: bro --theme light${R}`);
        p(`  ${DGRAY}       bro --theme dark${R}`);
        p(`  ${DGRAY}Theme tersedia: light, dark${R}\n`);
        process.exit(1);
    }
    const config = loadConfig();
    config.theme = newTheme;
    saveConfig(config);
    theme = THEMES[newTheme];
    p(`  ${FOREST}${BOLD}✓${R}  Theme diubah ke: ${newTheme}\n`);
}

async function cmdChat(query) {
    const apiKey = getApiKey();
    const config = loadConfig();
    const session = loadSession();
    
    query = validateInput(query);
    session.push({ role: 'user', content: query });
    
    // Skip user bubble display - just show loading
    
    const { spawn } = await import('child_process');
    const curl = spawn('curl', [
        '-sf', '--max-time', '60',
        '-X', 'POST', 'https://openrouter.ai/api/v1/chat/completions',
        '-H', `Authorization: Bearer ${apiKey}`,
        '-H', 'Content-Type: application/json',
        '-H', 'HTTP-Referer: https://localhost',
        '-H', 'X-Title: Bro CLI',
        '-d', JSON.stringify({
            model: config.model,
            messages: session,
            max_tokens: 2048
        })
    ]);
    
    currentCurl = curl;
    let responseData = '';
    let errorData = '';
    
    curl.stdout.on('data', (data) => { responseData += data; });
    curl.stderr.on('data', (data) => { errorData += data; });
    
    const spinnerInt = showSpinner(curl.pid);
    
    return new Promise((resolve, reject) => {
        curl.on('close', (code) => {
            clearInterval(spinnerInt);
            currentCurl = null;
            
            if (code !== 0) {
                // Parse curl error
                if (errorData.includes('could not resolve host') || errorData.includes('Name or service not known')) {
                    showError('Network Error', 'Gagal konek ke server.', ERROR_HELP['NETWORK']);
                } else if (errorData.includes('timed out')) {
                    showError('Timeout', 'Request terlalu lama.', ERROR_HELP['TIMEOUT']);
                } else {
                    showError('Network Error', 'Gagal konek ke OpenRouter.', ERROR_HELP['NETWORK']);
                }
                process.exit(1);
            }
            
            try {
                const data = JSON.parse(responseData);
                
                if (data.error) {
                    const errCode = data.error.code || 'API';
                    const help = ERROR_HELP[errCode] || ERROR_HELP['NETWORK'];
                    showError('API Error', data.error.message, help);
                    process.exit(1);
                }
                
                const reply = data.choices[0].message.content;
                const tokens = data.usage?.total_tokens || 0;
                
                session.push({ role: 'assistant', content: reply });
                if (session.length > 40) {
                    session.splice(0, session.length - 40);
                }
                saveSession(session);
                
                aiBubble(reply);
                p(`\n${MGRAY}────────────────────────────────${R}`);
                p(`${MGRAY}⚡ ${tokens} token${R} · ${DGRAY}${config.model}${R}`);
                
                resolve();
            } catch (e) {
                p(`  ${RED}${BOLD}✗${R}  Parse Error: Response tidak valid\n`);
                process.exit(1);
            }
        });
    });
}

// Main
async function main() {
    setupSignalHandler();
    ensureConfig();
    getApiKey();
    
    // Check for pipe input early
    const pipeInput = await checkPipeInput();
    const hasArgs = args.length > 0;
    
    // If no args but have pipe input, use it as query
    if (pipeInput && !hasArgs) {
        await cmdChat(pipeInput);
        return;
    }
    
    // If no args and no pipe, show help
    if (!hasArgs) {
        showHelp();
        return;
    }
    
    switch (command) {
        case '--help':
        case '-h':
            showHelp();
            break;
            
        case '--model':
        case '-m':
            await selectModel();
            break;
            
        case '--new':
        case '-n':
            cmdNew();
            break;
            
        case '--history':
        case '-y':
            cmdHistory();
            break;
            
        case '--clear':
        case '-c':
            saveSession([]);
            p(`  ${FOREST}${BOLD}✓${R}  History dihapus.\n`);
            break;
            
        case '--read':
        case '-r':
            if (!args[1]) {
                p(`  ${RED}${BOLD}✗${R}  Usage: bro --read <file> [prompt]`);
                process.exit(1);
            }
            const readPrompt = args[2] || 'Jelaskan isi file ini';
            const readQuery = cmdRead(args[1], readPrompt);
            await cmdChat(readQuery);
            break;
            
        case '--write':
        case '-w':
            if (!args[1] || !args[2]) {
                p(`  ${RED}${BOLD}✗${R}  Usage: bro --write <file> <content>`);
                process.exit(1);
            }
            cmdWrite(args[1], args[2]);
            break;
            
case '--append':
            cmdAppend(args[1], args[2]);
            break;
            
        case '--theme':
        case '-t':
            cmdTheme(args[1]);
            break;
            
        case '--config':
            cmdConfig();
            break;
            
        case '--stream':
        case '-s':
            if (pipeInput) {
                await cmdChatStreaming(pipeInput);
            } else if (!args[1]) {
                showError('Usage', 'bro --stream "pertanyaan" atau echo "text" | bro --stream');
                process.exit(1);
            } else {
                await cmdChatStreaming(args.slice(1).join(' '));
            }
            break;
            
        case '--interactive':
        case '-i':
            await interactiveMode();
            break;
            
        case '--export':
            cmdExport(args[1]);
            break;
            
        case '--import':
            cmdImport(args[1]);
            break;
            
        case '--stats':
            cmdStats();
            break;
            
        case '--verbose':
        case '-v':
            process.env.BRO_VERBOSE = '1';
            await cmdChat(args.slice(1).join(' '));
            break;
            
        case '--reset':
            // Reset config and session
            if (fs.existsSync(CONFIG_FILE)) fs.unlinkSync(CONFIG_FILE);
            if (fs.existsSync(SESSION_FILE)) fs.unlinkSync(SESSION_FILE);
            p(`  ${FOREST}${BOLD}✓${R}  Reset selesai. Semua config & session dihapus.\n`);
            break;
            
        case '':
            showHelp();
            break;
            
        default:
            // Check if it's a flag (starts with -)
            if (command.startsWith('-')) {
                showError('Flag Tidak Dikenal', command, 'Ketik bro --help untuk lihat semua perintah');
                process.exit(1);
            }
            // Otherwise treat as chat query
            await cmdChat(args.join(' '));
    }
}

main();