export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
ZSH_DISABLE_COMPFIX="true"
plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Catppuccin Mocha prompt (truecolor): green arrow, mauve cwd, blue git branch
ZSH_THEME_GIT_PROMPT_PREFIX="%F{#89b4fa}(%F{#f38ba8}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f "
ZSH_THEME_GIT_PROMPT_DIRTY="%F{#f9e2af} *%F{#89b4fa})"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{#89b4fa})"
PROMPT='%(?.%F{#a6e3a1}.%F{#f38ba8})➜%f %F{#cba6f7}%B%c%b%f $(git_prompt_info)'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6c7086"

export EDITOR=nano
alias ll='ls -lah --color=auto'
alias ls='ls --color=auto'

# pfetch once per graphical terminal, not in nested shells
if [[ -o interactive && -z "$FETCH_SHOWN" && "$SHLVL" -le 2 && -n "$WAYLAND_DISPLAY" && -z "$TMUX" ]]; then
  export FETCH_SHOWN=1
  command -v pfetch >/dev/null && pfetch 2>/dev/null
fi
export PATH="$HOME/.local/bin:$PATH"

# Claude Code: treat this environment as a sandbox
export IS_SANDBOX=1

# Start interactive shells in /home/source instead of /root (only when opened at ~)
if [[ -o interactive && -z "$CLAUDECODE" && "$PWD" == "$HOME" ]]; then
  cd /home/source
fi
