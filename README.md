# PR-Agent Installer

One-click installer for setting up PR-Agent with local Ollama AI model on Windows.

## What It Does

This installer automatically sets up:
- **Ollama** - Local AI runtime
- **qwen2.5-coder:7b** - AI model optimized for code review (~4.7GB)
- **PR-Agent** - Automatic code review for GitHub Pull Requests
- **GitHub Actions Runner** - Self-hosted runner on your machine

## Requirements

- **Windows 10/11**
- **NVIDIA GPU** with 6GB+ VRAM (recommended: RTX 3060 or better)
- **GitHub account** with a repository
- **Admin access** to the repository

## Quick Start

1. **Double-click `install.bat`** (Right-click → Run as Administrator for best results)
2. Follow the prompts:
   - Enter your GitHub repository URL
   - Get the runner token from GitHub (the installer will show you where)
   - Choose a name for your runner
3. Copy `workflow/pr_agent.yml` to your repository at `.github/workflows/pr_agent.yml`
4. Start the runner when prompted
5. Create a Pull Request to test!

## What You Get

After installation:
- Automatic code review on every Pull Request
- AI-generated PR descriptions
- Code improvement suggestions
- Everything runs locally on your GPU (no API costs!)

## Manual Commands

### Start the Runner
```powershell
cd C:\pr-agent-runner  # or your custom path
.\run.cmd
```

### Install as Windows Service (Auto-start)
```powershell
cd C:\pr-agent-runner
.\svc.cmd install
.\svc.cmd start
```

### Check Ollama Status
```powershell
ollama list
ollama serve  # if not running
```

## Folder Structure

```
pr-agent-installer/
├── install.bat          # One-click installer
├── workflow/
│   └── pr_agent.yml     # GitHub Actions workflow (copy to your repo)
├── scripts/
│   └── start-runner.bat # Quick-start script
└── README.md            # This file
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "winget not found" | Install App Installer from Microsoft Store |
| "Ollama not found" after install | Restart your terminal/PC |
| Runner shows "Offline" | Run `.\run.cmd` in the runner folder |
| Model too slow | Use a smaller model or reduce context window |

## Supported Models

You can change the model in the workflow file. Options:
- `ollama/qwen2.5-coder:7b` (default, ~4.7GB, good for 8GB VRAM)
- `ollama/qwen2.5-coder:3b` (smaller, ~2GB, faster but less accurate)
- `ollama/codellama:7b` (alternative, ~4GB)

## License

MIT License - Feel free to modify and share!

---

Made with ❤️ for developers who want free, local AI code reviews.

---

# 🌐 GROQ CLOUD VERSION (No GPU Required!)

If you don't have a GPU or want to run on a VPS/server, use the Groq-powered version.

## Quick Start (Groq)

1. **Get a FREE Groq API key** from: https://console.groq.com/keys
2. **Run `install-groq.bat`** (instead of install.bat)
3. Follow the prompts
4. Add `GROQ_API_KEY` as a GitHub Secret
5. Copy `workflow-groq/pr_agent.yml` to your repo

## Requirements (Groq Version)

- ✅ Any Windows machine (no GPU needed!)
- ✅ Works on cheap VPS ($5/month)
- ✅ FREE Groq API (14,400 requests/day)
- ✅ Python 3.8+

## Groq vs Ollama Comparison

| Feature | Ollama (Local) | Groq (Cloud) |
|---------|---------------|--------------|
| **GPU Required** | ✅ Yes (6GB+ VRAM) | ❌ No |
| **Works on VPS** | ❌ No | ✅ Yes |
| **Cost** | Free (electricity) | Free (API) |
| **Speed** | Fast | Very Fast |
| **Privacy** | Code stays local | Code sent to cloud |
| **Setup** | Complex | Simple |

## Files for Groq Version

```
pr-agent-installer/
├── install-groq.bat           # Groq installer
└── workflow-groq/
    └── pr_agent.yml           # Groq workflow
```

