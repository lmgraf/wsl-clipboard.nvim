# wsl-clipboard.nvim

**The fastest way to sync your Windows and Neovim clipboards on WSL.** This plugin eliminates the latency commonly found in WSL clipboard providers by offering event-driven synchronization strategies.


## 🚀 Features

* **High Performance:** Replaces slow default providers with optimized `vim.system` calls.
* **Modular Modes:** Choose between accuracy and speed based on your workflow.
* **Windows History Integration:** Fully compatible with `Win + V`. Every yank is pushed instantly to your Windows clipboard history.


## 📦 Installation

Before installing, please make sure your system meets the **requirements** below.

Using **lazy.nvim**:

```lua
{
  "lmgraf/wsl-clipboard.nvim",
  opts = {
    mode = "sync", -- options: "system", "sync", "focus"
  },
}

```

Using **packer.nvim**:

```lua
use {
  "lmgraf/wsl-clipboard.nvim",
  config = function()
    require('wsl-clipboard').setup({
      mode = "sync", -- options: "system", "sync", "focus"
    })
  end
}

```

## ⚙️ Configuration

| Mode | Description |
| --- | --- |
| `sync` | **Recommended.** Immediate push to Windows on yank; pulls from Windows on focus gained. |
| `focus` | **The Fastest.** Only synchronizes when you switch windows (FocusLost/FocusGained). |
| `system` | **Traditional.** Uses the native Neovim provider. Reliable but **slow**. |


## 🛠 Requirements

* Neovim 0.10+
* WSL2 (Ubuntu, Debian, etc.)
* **Windows Host Utilities:**
  * `clip.exe` (Standard on Windows)
  * `powershell.exe` (Standard on Windows)
* **Linux Utilities:**
  * `iconv` (Usually pre-installed on most distros)
  * `sed` (Standard on Linux)

