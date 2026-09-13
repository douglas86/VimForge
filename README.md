# 🏷️ VimForge

![logo](./assets/logo.png)

---

## 📌 Table of Content

1. Getting Started

---

## 📌 Getting Started

<!-- TODO: I still need to create a bash script to make installing this easier -->

_Installing Neovim on the command line_

```
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm nvim-linux-x86_64.tar.gz
nvim --version
git clone git@github.com:douglas86/VimForge.git ~/.config/nvim
```

_Installtion Lazygit_

```
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar -xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz
```

_Installing ripgrep for telescope_

```
sudo apt update && sudo apt install -y ripgrep
sudo apt install -y fd-find
```

_Installing nerdfonts_

```
sudo apt install -y fonts-firacode
```

_Fetch api key for using Gemini_

https://aistudio.google.com/app/api-keys?project=mental-health-430613

_Installing packages for copying and pasting from the clipboard_

```
sudo apt install wl-clipboard xclip
```



_Removing Neovim from your system_

Step 1: Remove the application directory from opt
sudo rm -rf /opt/nvim-linux-x86_64
sudo rm -f /usr/local/bin/nvim
sudo rm -f /usr/local/bin/lazygit

Step 2: Remove leftover downloads
rm -f nvim-linux-x86_64.tar.gz

Step 3: Purge user config, plugins, state and cache
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim


---
