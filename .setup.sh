#!/usr/bin/env bash
set -e
set -u

# ============================================================
# 🚀 Dotfiles Setup Script (Linux + Homebrew)
# ============================================================

# -----------------------------
# 🍺 1. Installer Homebrew (hvis mangler)
# -----------------------------
if ! command -v brew >/dev/null 2>&1; then
  echo "🍺 Installerer Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.bashrc"
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.zshrc"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
else
  echo "✅ Homebrew allerede installeret."
fi

# -----------------------------
# 🧠 2. Sørg for at login shells også får Homebrew PATH
# -----------------------------
if ! grep -Fxq 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' "$HOME/.zprofile" 2>/dev/null; then
  echo '💡 Tilføjer Homebrew PATH-init til ~/.zprofile...'
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
fi

# -----------------------------
# 🔄 3. Opdater og opgrader Homebrew
# -----------------------------
echo "🔄 Opdaterer Homebrew..."
brew update && brew upgrade

# -----------------------------
# ⚙️ 4. Installer nødvendige pakker og plugins
# -----------------------------
echo "⚙️ Installerer værktøjer og Zsh-plugins..."
brew install \
  git \
  zsh \
  stow \
  neovim \
  starship \
  curl \
  wget \
  unzip \
  make \
  zsh-syntax-highlighting \
  zsh-autosuggestions

# -----------------------------
# 🧩 5. Symlink dotfiles med GNU Stow (før .zshrc justering)
# -----------------------------
echo "🔗 Opretter symlinks med stow..."
cd "$(dirname "$0")"

if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  echo "🧹 Fjerner eksisterende lokal .zshrc for at undgå konflikt..."
  rm -f "$HOME/.zshrc"
fi

stow .

# -----------------------------
# 💫 6. Tilføj Homebrew + Starship + plugin blok i toppen af ~/.zshrc
# -----------------------------
ZDOTDIR="$HOME/.zshrc"
[ -f "$ZDOTDIR" ] || touch "$ZDOTDIR"

# Fjern evt. skjulte karakterer
sed -i 's/\xC2\xA0/ /g' "$ZDOTDIR" 2>/dev/null || true
sed -i '1s/^\xEF\xBB\xBF//' "$ZDOTDIR" 2>/dev/null || true

# Indsæt top-blok hvis den ikke findes
if ! grep -q "brew shellenv" "$ZDOTDIR" 2>/dev/null; then
  echo "💫 Tilføjer Homebrew + Starship blok til toppen af .zshrc..."
  cat <<'EOF' | sed -i '1r /dev/stdin' "$ZDOTDIR"
# --- Homebrew environment (always first) ---
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# --- Plugins (after PATH is set) ---
if [ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
if [ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# --- Starship prompt ---
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

EOF
fi

# -----------------------------
# 🐚 7. Sæt Zsh som standard shell (via Homebrew)
# -----------------------------
ZSH_PATH="$(brew --prefix)/bin/zsh"

if ! grep -Fxq "$ZSH_PATH" /etc/shells; then
  echo "💡 Tilføjer Homebrew Zsh til /etc/shells..."
  echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi

if [ "$SHELL" != "$ZSH_PATH" ]; then
  echo "💡 Sætter Zsh som standardshell..."
  chsh -s "$ZSH_PATH"
fi

# -----------------------------
# ✨ 8. Start Zsh med ny config
# -----------------------------
echo
echo "✅ Setup færdigt! Starter Zsh med Starship og plugins..."
exec "$ZSH_PATH" -l

# -----------------------------
# 🏠 9. Slut med at vise 'home'
# -----------------------------
home
