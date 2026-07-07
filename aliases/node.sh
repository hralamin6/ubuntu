#!/usr/bin/env zsh
# =============================================================================
# aliases/node.sh — Node.js, npm, yarn, pnpm aliases
# =============================================================================

# ---------------------------------------------------------------------------
# NODE
# ---------------------------------------------------------------------------
alias node='node --experimental-vm-modules'
alias nodei='node -i'                       # REPL
alias nodec='node -e'                       # Run code
alias nodev='node --version'
alias nvmv='nvm --version'

# ---------------------------------------------------------------------------
# NPM
# ---------------------------------------------------------------------------
alias ni='npm install'
alias niS='npm install --save'
alias niD='npm install --save-dev'
alias niE='npm install --save-exact'
alias nig='npm install --global'
alias nu='npm update'
alias nug='npm update --global'
alias nr='npm run'
alias nrs='npm run start'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrt='npm run test'
alias nrl='npm run lint'
alias nrp='npm run preview'
alias nrw='npm run watch'
alias nrm='npm run migrate'
alias nrdb='npm run db:seed'
alias nun='npm uninstall'
alias nung='npm uninstall --global'
alias nls='npm list'
alias nlsg='npm list --global --depth=0'
alias nout='npm outdated'
alias noutg='npm outdated --global'
alias nci='npm ci'                           # Clean install
alias npm-reset='rm -rf node_modules && npm install'
alias ncheck='npm audit'
alias nfix='npm audit fix'
alias npub='npm publish'
alias npak='npm pack'
alias nlink='npm link'
alias nunlink='npm unlink'
alias nping='npm ping'
alias nscripts='npm run'
alias nwhich='npm bin'
alias nconfig='npm config list'
alias ncache='npm cache clean --force'
alias nv='npm --version'
alias ninfo='npm info'
alias nwho='npm whoami'

# ---------------------------------------------------------------------------
# YARN
# ---------------------------------------------------------------------------
if command -v yarn &>/dev/null; then
  alias yi='yarn install'
  alias ya='yarn add'
  alias yad='yarn add --dev'
  alias yag='yarn global add'
  alias yr='yarn run'
  alias yrs='yarn start'
  alias yrd='yarn dev'
  alias yrb='yarn build'
  alias yrt='yarn test'
  alias yrl='yarn lint'
  alias yu='yarn upgrade'
  alias yug='yarn global upgrade'
  alias yout='yarn outdated'
  alias yrm='yarn remove'
  alias yrmg='yarn global remove'
  alias yls='yarn list'
  alias ylsg='yarn global list'
  alias yupgrade='yarn upgrade-interactive'
  alias yclean='rm -rf node_modules && yarn install'
  alias yaudit='yarn audit'
fi

# ---------------------------------------------------------------------------
# PNPM
# ---------------------------------------------------------------------------
if command -v pnpm &>/dev/null; then
  alias pi='pnpm install'
  alias pa='pnpm add'
  alias pad='pnpm add --save-dev'
  alias pag='pnpm add --global'
  alias pu='pnpm update'
  alias pun='pnpm uninstall'
  alias pr='pnpm run'
  alias prs='pnpm start'
  alias prd='pnpm dev'
  alias prb='pnpm build'
  alias prt='pnpm test'
  alias prl='pnpm lint'
  alias pout='pnpm outdated'
  alias pls='pnpm list'
  alias plsg='pnpm list --global'
  alias pci='pnpm install --frozen-lockfile'
  alias pclean='rm -rf node_modules && pnpm install'
fi

# ---------------------------------------------------------------------------
# BUN
# ---------------------------------------------------------------------------
if command -v bun &>/dev/null; then
  alias bi='bun install'
  alias ba='bun add'
  alias bad='bun add --dev'
  alias br='bun run'
  alias brd='bun dev'
  alias brb='bun build'
  alias brt='bun test'
  alias brm='bun remove'
  alias bx='bunx'
fi

# ---------------------------------------------------------------------------
# NODE VERSION MANAGEMENT
# ---------------------------------------------------------------------------
# NVM (if available — lazy loaded in zshrc)
alias nvmls='nvm ls'
alias nvmlsr='nvm ls-remote'
alias nvmi='nvm install'
alias nvmuse='nvm use'
alias nvmd='nvm use default'
alias nvmlts='nvm install --lts && nvm use --lts'
alias nvmcur='nvm current'
alias nvmalias='nvm alias'

# ---------------------------------------------------------------------------
# MISC NODE TOOLS
# ---------------------------------------------------------------------------
alias typescript='npx tsc'
alias tsc='npx tsc'
alias ts-node='npx ts-node'
alias eslint='npx eslint'
alias prettier='npx prettier'
alias serve='npx serve'
alias json-server='npx json-server'
alias concurrently='npx concurrently'
alias webpack='npx webpack'
alias vite='npx vite'
alias next='npx next'
alias nuxt='npx nuxt'
