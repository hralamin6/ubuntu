#!/usr/bin/env zsh
# =============================================================================
# functions/laravel.sh — Laravel, PHP, and project functions (20+)
# =============================================================================

# Laravel project setup
new-laravel() {
  local name="${1:-laravel-app}"
  local version="${2:-}"

  echo "Creating Laravel project: ${name}"

  if [[ -n "${version}" ]]; then
    composer create-project laravel/laravel "${name}" "${version}"
  else
    composer create-project laravel/laravel "${name}"
  fi

  cd "${name}" || return 1
  cp .env.example .env
  php artisan key:generate

  echo ""
  echo "Laravel project created: ${name}"
  echo "Run: cd ${name} && php artisan serve"
}

# Quick project switch (cd + list)
project() {
  local projects_dir="${PROJECTS_DIR:-${HOME}/code}"

  if [[ -n "$1" ]]; then
    if [[ -d "${projects_dir}/$1" ]]; then
      cd "${projects_dir}/$1"
    else
      echo "Project '${1}' not found in ${projects_dir}" >&2
      return 1
    fi
  else
    if command -v fzf &>/dev/null; then
      local proj
      proj=$(find "${projects_dir}" -maxdepth 1 -type d | \
        tail -n +2 | \
        sed "s|${projects_dir}/||" | \
        fzf --preview "ls -la ${projects_dir}/{}" --prompt="Project: ")
      [[ -n "${proj}" ]] && cd "${projects_dir}/${proj}"
    else
      ls "${projects_dir}"
    fi
  fi
}

# PHP info for a specific extension
phpinfo() {
  local ext="${1:-}"
  if [[ -n "${ext}" ]]; then
    php -r "phpinfo(INFO_MODULES);" 2>/dev/null | grep -i "${ext}" || \
    php -m | grep -i "${ext}"
  else
    php -r "phpinfo();" | head -60
  fi
}

# Run artisan with auto-detect (handles sail)
artisan() {
  if [[ -f "sail" ]] || [[ -f "vendor/bin/sail" ]]; then
    local sail_cmd
    sail_cmd=$(command -v sail 2>/dev/null || echo "vendor/bin/sail")
    "${sail_cmd}" artisan "$@"
  elif [[ -f "artisan" ]]; then
    php artisan "$@"
  else
    echo "No artisan found in $(pwd)" >&2
    return 1
  fi
}

# Run composer with auto-detect (handles sail)
comp() {
  if [[ -f "sail" ]] || [[ -f "vendor/bin/sail" ]]; then
    local sail_cmd
    sail_cmd=$(command -v sail 2>/dev/null || echo "vendor/bin/sail")
    "${sail_cmd}" composer "$@"
  else
    composer "$@"
  fi
}

# Laravel log watcher with color
laravel-log() {
  local logfile="${1:-storage/logs/laravel.log}"

  if [[ ! -f "${logfile}" ]]; then
    echo "Log file not found: ${logfile}" >&2
    return 1
  fi

  if command -v bat &>/dev/null; then
    tail -f "${logfile}" | bat --style=plain --language=log --paging=never
  else
    tail -f "${logfile}"
  fi
}

# Laravel test runner with coverage
laravel-test() {
  local filter="${1:-}"

  if [[ -f "vendor/bin/pest" ]]; then
    if [[ -n "${filter}" ]]; then
      vendor/bin/pest --filter "${filter}"
    else
      vendor/bin/pest
    fi
  elif [[ -f "vendor/bin/phpunit" ]]; then
    if [[ -n "${filter}" ]]; then
      vendor/bin/phpunit --filter "${filter}"
    else
      vendor/bin/phpunit
    fi
  else
    php artisan test "${@}"
  fi
}

# Clear all Laravel caches in one go
laravel-clear-all() {
  echo "Clearing all Laravel caches..."
  php artisan cache:clear
  php artisan config:clear
  php artisan route:clear
  php artisan view:clear
  php artisan event:clear
  php artisan optimize:clear
  composer dump-autoload
  echo "Done."
}
alias laraclr='laravel-clear-all'

# Optimize Laravel for production
laravel-optimize() {
  echo "Optimizing Laravel for production..."
  composer install --no-dev --optimize-autoloader
  php artisan config:cache
  php artisan route:cache
  php artisan view:cache
  php artisan event:cache
  php artisan optimize
  echo "Done."
}

# Create a new Laravel API controller + model + migration + factory + seeder
laravel-scaffold() {
  local name="$1"
  if [[ -z "${name}" ]]; then
    echo "Usage: laravel-scaffold <ModelName>" >&2
    return 1
  fi

  php artisan make:model "${name}" --all
  echo "Scaffolded: Model, Controller, Migration, Factory, Seeder for ${name}"
}

# Run queue worker in background
laravel-queue() {
  local queue="${1:-default}"
  php artisan queue:work --queue="${queue}" --tries=3 --timeout=90 &
  echo "Queue worker started (PID: $!)"
}

# Open Tinker for quick REPL
tink() {
  if [[ -f "artisan" ]]; then
    php artisan tinker
  else
    echo "Not in a Laravel project directory." >&2
  fi
}

# Database seeder with confirmation
db-seed() {
  local seeder="${1:-}"
  echo -n "Seed database${seeder:+ with ${seeder}}? [y/N]: "
  read -r answer
  if [[ "${answer}" =~ ^[Yy]$ ]]; then
    if [[ -n "${seeder}" ]]; then
      php artisan db:seed --class="${seeder}"
    else
      php artisan db:seed
    fi
  fi
}

# Fresh migration with seeding
fresh-db() {
  echo -n "This will DROP ALL TABLES and re-migrate. Continue? [y/N]: "
  read -r answer
  if [[ "${answer}" =~ ^[Yy]$ ]]; then
    php artisan migrate:fresh --seed
    echo "Database refreshed and seeded."
  fi
}

# Artisan scheduler run once for testing
schedule-run() {
  php artisan schedule:run --verbose 2>&1
}

# Check PHP extensions
php-extensions() {
  php -m | sort | column
}

# Find PHP syntax errors
php-lint() {
  local dir="${1:-.}"
  find "${dir}" -name "*.php" -type f | \
    xargs -I{} php -l {} 2>&1 | \
    grep -v "No syntax errors"
}

# Start a local PHP mail server (MailHog alternative)
mailserver() {
  local port="${1:-1025}"
  php -r "
    \$server = stream_socket_server('tcp://0.0.0.0:${port}', \$errno, \$errstr);
    echo 'Mail debugging server on port ${port}\n';
    while (\$socket = stream_socket_accept(\$server, -1)) {
      stream_socket_shutdown(\$socket, STREAM_SHUT_RDWR);
    }
  "
}

# Composer security audit
composer-audit() {
  composer audit
}

# PHP version manager shortcuts (if phpenv or phpbrew)
php-switch() {
  local version="$1"
  if command -v phpenv &>/dev/null; then
    phpenv global "${version}"
  elif command -v update-alternatives &>/dev/null; then
    sudo update-alternatives --set php "/usr/bin/php${version}"
  else
    echo "No PHP version manager found." >&2
  fi
  php --version
}
