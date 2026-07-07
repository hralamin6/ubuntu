#!/usr/bin/env zsh
# =============================================================================
# functions/git.sh — Git helper functions (20+)
# =============================================================================

# Clean merged branches (interactive)
git-clean() {
  local default_branch="${1:-main}"
  echo "=== Branches merged into '${default_branch}' ==="
  git branch --merged "${default_branch}" | grep -v "^\*\|${default_branch}\|develop\|master"
  echo ""
  echo -n "Delete these branches? [y/N]: "
  read -r answer
  if [[ "${answer}" =~ ^[Yy]$ ]]; then
    git branch --merged "${default_branch}" | \
      grep -v "^\*\|${default_branch}\|develop\|master" | \
      xargs -r git branch -d
    echo "Cleaned merged branches."
  fi
}

# Interactive git log with fzf
fuzzy-git-log() {
  local commit
  commit=$(git log --oneline --color=always | \
    fzf --ansi --preview 'git show --stat {1}' | \
    awk '{print $1}')

  if [[ -n "${commit}" ]]; then
    git show "${commit}"
  fi
}

# Git commit with conventional commit format
git-commit-conventional() {
  local type="${1}"
  local scope="${2}"
  local message="${3}"

  if [[ -z "${type}" || -z "${message}" ]]; then
    echo "Usage: gcc <type> [scope] <message>"
    echo "Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build"
    return 1
  fi

  local commit_msg
  if [[ -n "${scope}" && "${scope}" != "${message}" ]]; then
    commit_msg="${type}(${scope}): ${message}"
  else
    commit_msg="${type}: ${scope}"
  fi

  git commit -m "${commit_msg}"
}
alias gcc='git-commit-conventional'

# Show what files changed in last N commits
git-changes() {
  local n="${1:-5}"
  git log --oneline -n "${n}" --name-status
}

# Interactive stash manager
git-stash-fzf() {
  local stash
  stash=$(git stash list | fzf --preview 'git stash show -p {1}' | awk -F: '{print $1}')
  if [[ -n "${stash}" ]]; then
    git stash apply "${stash}"
  fi
}

# Show git statistics for current repo
git-stats() {
  echo "=== Repository Statistics ==="
  printf "  %-25s %s\n" "Total commits:"    "$(git log --oneline | wc -l)"
  printf "  %-25s %s\n" "Contributors:"     "$(git shortlog -s | wc -l)"
  printf "  %-25s %s\n" "Tracked files:"    "$(git ls-files | wc -l)"
  printf "  %-25s %s\n" "Branches:"         "$(git branch --all | wc -l)"
  printf "  %-25s %s\n" "Tags:"             "$(git tag | wc -l)"
  printf "  %-25s %s\n" "Remote:"           "$(git remote get-url origin 2>/dev/null || echo 'none')"
  printf "  %-25s %s\n" "Current branch:"   "$(git branch --show-current)"
  printf "  %-25s %s\n" "Repo size:"        "$(git count-objects -vH | grep 'size-pack' | awk '{print $2, $3}')"
  echo ""
  echo "=== Top 5 Contributors ==="
  git shortlog -sn | head -5
}

# Undo last commit (keep changes staged)
git-undo() {
  git reset --soft HEAD~1
  echo "Last commit undone. Changes are staged."
}

# Squash last N commits
git-squash() {
  local n="${1:-2}"
  git rebase -i "HEAD~${n}"
}

# Create a release tag
git-release() {
  local version="$1"
  local message="${2:-Release ${version}}"

  if [[ -z "${version}" ]]; then
    echo "Usage: git-release <version> [message]" >&2
    return 1
  fi

  git tag -a "v${version}" -m "${message}"
  git push origin "v${version}"
  echo "Released: v${version}"
}

# Show diff with syntax highlighting
git-diff-fancy() {
  git diff --color=always "$@" | \
    if command -v bat &>/dev/null; then
      bat --style=plain --language=diff --paging=always
    elif command -v diff-highlight &>/dev/null; then
      diff-highlight | less -R
    else
      less -R
    fi
}

# Clone and cd into repo
gitcd() {
  git clone "$1" && cd "$(basename "${1%.git}")"
}

# Show branches sorted by last commit date
git-recent-branches() {
  local n="${1:-10}"
  git for-each-ref --sort=committerdate refs/heads/ \
    --format='%(committerdate:short) %(refname:short) %(subject)' | \
    tail -"${n}"
}

# Show all remote branches not yet merged
git-unmerged() {
  local base="${1:-main}"
  git branch -r --no-merged "${base}" | grep -v HEAD
}

# Interactive branch switcher with fzf
git-switch-fzf() {
  local branch
  branch=$(git branch --all | grep -v HEAD | \
    fzf --preview 'git log --oneline --graph --date=short --pretty=format:"%C(auto)%h %Cblue%ad %Creset%s %Cgreen%an" {-1}' | \
    sed 's/.* //' | sed 's#remotes/[^/]*/##')

  if [[ -n "${branch}" ]]; then
    git switch "${branch}" 2>/dev/null || git checkout "${branch}"
  fi
}
alias gsf='git-switch-fzf'

# Add all and commit in one command
git-quick-commit() {
  local message="$*"
  if [[ -z "${message}" ]]; then
    echo "Usage: gqc <message>" >&2
    return 1
  fi
  git add --all && git commit -m "${message}"
}
alias gqc='git-quick-commit'

# Pull request (via gh cli)
git-pr() {
  if command -v gh &>/dev/null; then
    gh pr create --fill
  else
    echo "GitHub CLI (gh) not installed." >&2
  fi
}

# Show current branch's log vs origin
git-ahead-behind() {
  local branch
  branch=$(git branch --show-current)
  local remote_branch="origin/${branch}"

  if ! git rev-parse --verify "${remote_branch}" &>/dev/null; then
    echo "No remote tracking branch found."
    return 1
  fi

  local ahead behind
  ahead=$(git rev-list --count "${remote_branch}..HEAD" 2>/dev/null)
  behind=$(git rev-list --count "HEAD..${remote_branch}" 2>/dev/null)

  printf "Branch '%s':\n" "${branch}"
  printf "  Ahead of origin by:  %s commit(s)\n" "${ahead}"
  printf "  Behind origin by:    %s commit(s)\n" "${behind}"
}

# Interactive git add (fzf)
git-add-fzf() {
  git status --short | \
    fzf --multi --preview 'git diff {2}' | \
    awk '{print $2}' | \
    xargs git add
}
alias gaf='git-add-fzf'

# Today's git activity
git-standup() {
  git log \
    --since="midnight" \
    --author="$(git config user.email)" \
    --oneline \
    --all \
    --no-merges 2>/dev/null || echo "No commits today."
}
