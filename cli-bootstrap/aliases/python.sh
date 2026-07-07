#!/usr/bin/env zsh
# =============================================================================
# aliases/python.sh — Python, pip, and virtualenv aliases
# =============================================================================

# ---------------------------------------------------------------------------
# PYTHON
# ---------------------------------------------------------------------------
alias py='python3'
alias py2='python2'
alias py3='python3'
alias python='python3'
alias pip='pip3'
alias pyv='python3 --version'
alias pypath='python3 -c "import sys; print(sys.path)"'
alias pysite='python3 -c "import site; print(site.getsitepackages())"'
alias pydoc='python3 -m pydoc'
alias pytest='python3 -m pytest'
alias ptest='python3 -m pytest'
alias ptestv='python3 -m pytest -v'
alias ptestvv='python3 -m pytest -vv'
alias ptests='python3 -m pytest -s'             # Show stdout
alias ptestc='python3 -m pytest --cov'
alias ptestr='python3 -m pytest --lf'           # Last failed
alias pycheck='python3 -m py_compile'
alias pylint='python3 -m pylint'
alias pyflakes='python3 -m pyflakes'
alias mypy='python3 -m mypy'
alias black='python3 -m black'
alias isort='python3 -m isort'
alias ruff='python3 -m ruff'
alias pyserve='python3 -m http.server'
alias pyjson='python3 -m json.tool'
alias pyprofile='python3 -m cProfile'

# ---------------------------------------------------------------------------
# PIP
# ---------------------------------------------------------------------------
alias pipi='pip3 install'
alias pipiu='pip3 install --upgrade'
alias pipir='pip3 install -r requirements.txt'
alias pipird='pip3 install -r requirements-dev.txt'
alias pipu='pip3 install --upgrade pip'
alias piplist='pip3 list'
alias pipfreeze='pip3 freeze'
alias pipfreeze-req='pip3 freeze > requirements.txt'
alias pipdep='pip3 show'
alias pipoutdated='pip3 list --outdated'
alias pipupgradeall='pip3 list --outdated --format=freeze | grep -v "^-e" | cut -d = -f 1 | xargs -n1 pip3 install -U'
alias pipr='pip3 uninstall'
alias pipra='pip3 uninstall -r requirements.txt'
alias pipsearch='pip3 search'  # Note: may be disabled on newer pip
alias pipcheck='pip3 check'

# ---------------------------------------------------------------------------
# VIRTUALENV / VENV
# ---------------------------------------------------------------------------
alias venv='python3 -m venv'
alias venv-create='python3 -m venv venv'
alias venv-activate='source venv/bin/activate'
alias va='source venv/bin/activate'
alias vd='deactivate'
alias venv-clear='rm -rf venv && python3 -m venv venv && pip3 install -r requirements.txt'

# conda shortcuts (if available)
if command -v conda &>/dev/null; then
  alias ca='conda activate'
  alias cda='conda deactivate'
  alias cl='conda env list'
  alias ccr='conda env create'
  alias crm='conda env remove'
  alias ci='conda install'
  alias cu='conda update'
  alias cs='conda search'
fi

# ---------------------------------------------------------------------------
# POETRY
# ---------------------------------------------------------------------------
if command -v poetry &>/dev/null; then
  alias po='poetry'
  alias poi='poetry install'
  alias por='poetry run'
  alias pos='poetry shell'
  alias poa='poetry add'
  alias pod='poetry remove'
  alias pou='poetry update'
  alias poshow='poetry show'
  alias pobuild='poetry build'
  alias popub='poetry publish'
  alias ponew='poetry new'
  alias poconfig='poetry config --list'
  alias pytest='poetry run pytest'
fi

# ---------------------------------------------------------------------------
# JUPYTER
# ---------------------------------------------------------------------------
alias jn='jupyter notebook'
alias jl='jupyter lab'
alias jnbconv='jupyter nbconvert'

# ---------------------------------------------------------------------------
# MISC
# ---------------------------------------------------------------------------
alias python-server='python3 -m http.server 8000'
alias python-json='python3 -m json.tool'
alias python-sm='python3 -m smtpd -n -c DebuggingServer localhost:1025'
