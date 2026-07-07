#!/usr/bin/env zsh
# =============================================================================
# aliases/git.sh — Git workflow aliases
# =============================================================================

# ---------------------------------------------------------------------------
# CORE GIT
# ---------------------------------------------------------------------------
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gai='git add --interactive'
alias gc='git commit'
alias gcm='git commit --message'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gcf='git commit --fixup'
alias gcs='git commit --squash'
alias gcv='git commit --verbose'
alias gs='git status --short --branch'
alias gst='git status'
alias gss='git status -s'
alias gd='git diff'
alias gdc='git diff --cached'
alias gds='git diff --stat'
alias gdw='git diff --word-diff'
alias gdn='git diff --name-only'

# ---------------------------------------------------------------------------
# BRANCH
# ---------------------------------------------------------------------------
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'
alias gbm='git branch --move'
alias gbc='git checkout -b'
alias gbr='git branch --remote'
alias gbl='git branch --sort=-committerdate --format="%(committerdate:short) %(refname:short)"'

# ---------------------------------------------------------------------------
# CHECKOUT
# ---------------------------------------------------------------------------
alias gco='git checkout'
alias gcom='git checkout main'
alias gcod='git checkout develop'
alias gcop='git checkout --patch'

# Switch (modern git)
alias gsw='git switch'
alias gswc='git switch --create'
alias gswm='git switch main'
alias gswd='git switch develop'

# ---------------------------------------------------------------------------
# LOG
# ---------------------------------------------------------------------------
alias gl='git log --oneline --graph --decorate --color'
alias gll='git log --oneline --graph --decorate --all --color'
alias glg='git log --graph --abbrev-commit --decorate --format=format:"%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)" --all'
alias glp='git log --patch --stat'
alias gls='git log --stat'
alias glf='git log --follow -p'        # Follow file renames
alias gla='git log --all --oneline'
alias glb='git log --branches --oneline'

# ---------------------------------------------------------------------------
# PUSH / PULL
# ---------------------------------------------------------------------------
alias gps='git push'
alias gpso='git push origin'
alias gpsf='git push --force-with-lease'
alias gpst='git push --tags'
alias gpl='git pull'
alias gplo='git pull origin'
alias gplr='git pull --rebase'

# ---------------------------------------------------------------------------
# FETCH
# ---------------------------------------------------------------------------
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'

# ---------------------------------------------------------------------------
# REMOTE
# ---------------------------------------------------------------------------
alias gr='git remote -v'
alias gra='git remote add'
alias grr='git remote remove'
alias gru='git remote update'
alias grf='git remote prune origin'

# ---------------------------------------------------------------------------
# STASH
# ---------------------------------------------------------------------------
alias gsl='git stash list'
alias gss='git stash show --text'
alias gsp='git stash pop'
alias gsa='git stash apply'
alias gsd='git stash drop'
alias gsc='git stash clear'
alias gspush='git stash push'

# ---------------------------------------------------------------------------
# REBASE
# ---------------------------------------------------------------------------
alias grb='git rebase'
alias grbi='git rebase --interactive'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbs='git rebase --skip'
alias grbm='git rebase main'
alias grbd='git rebase develop'

# ---------------------------------------------------------------------------
# MERGE
# ---------------------------------------------------------------------------
alias gm='git merge'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gmff='git merge --ff-only'
alias gmno='git merge --no-ff'

# ---------------------------------------------------------------------------
# RESET / UNDO
# ---------------------------------------------------------------------------
alias gunstage='git reset HEAD --'
alias gundo='git reset --soft HEAD~1'
alias gnuke='git reset --hard HEAD'
alias grh='git reset --hard'
alias grs='git reset --soft'

# ---------------------------------------------------------------------------
# CHERRY-PICK
# ---------------------------------------------------------------------------
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'

# ---------------------------------------------------------------------------
# TAG
# ---------------------------------------------------------------------------
alias gt='git tag'
alias gta='git tag --annotate'
alias gtl='git tag --list'
alias gtd='git tag --delete'

# ---------------------------------------------------------------------------
# UTILS
# ---------------------------------------------------------------------------
alias gignore='git check-ignore -v'
alias groot='git rev-parse --show-toplevel'
alias gwhoami='git config user.name && git config user.email'
alias gauthors='git shortlog -sn --all'
alias gcount='git log --oneline | wc -l'
alias gclean='git clean -fd'
alias gcleanX='git clean -fdX'       # Remove ignored files
alias gsub='git submodule update --init --recursive'
alias gsize='git count-objects -vH'

# ---------------------------------------------------------------------------
# LAZYGIT
# ---------------------------------------------------------------------------
if command -v lazygit &>/dev/null; then
  alias lg='lazygit'
  alias lgg='lazygit'
fi

# ---------------------------------------------------------------------------
# GITHUB CLI
# ---------------------------------------------------------------------------
if command -v gh &>/dev/null; then
  alias ghpr='gh pr create'
  alias ghprl='gh pr list'
  alias ghprc='gh pr checkout'
  alias ghrpo='gh repo view --web'
  alias ghci='gh run list'
  alias ghwatch='gh run watch'
fi
