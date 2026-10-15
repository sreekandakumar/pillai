#!/usr/bin/env bash
# Spins up a throwaway WordPress (SQLite, PHP built-in server) in ./wp-test
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)/wp-test"; PORT="${PORT:-8080}"
if [ ! -f "$DIR/wp-config.php" ]; then
  mkdir -p "$DIR"; cd "$DIR"
  curl -sSL https://wordpress.org/latest.tar.gz | tar xz --strip-components=1
  curl -sSL -o /tmp/sqlite.zip https://downloads.wordpress.org/plugin/sqlite-database-integration.latest-stable.zip
  unzip -q -o /tmp/sqlite.zip -d wp-content/plugins/
  P="$DIR/wp-content/plugins/sqlite-database-integration"
  sed "s#{SQLITE_IMPLEMENTATION_FOLDER_PATH}#$P#; s#{SQLITE_PLUGIN}#sqlite-database-integration/load.php#" "$P/db.copy" > wp-content/db.php
  sed "s/database_name_here/wp/; s/username_here/wp/; s/password_here/wp/" wp-config-sample.php > wp-config.php
  curl -sSL -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  php /tmp/wp-cli.phar --allow-root core install --url="http://localhost:$PORT" --title="Pillai Test" \
    --admin_user=admin --admin_password=admin123 --admin_email=sree@ananthapuri.com --skip-email
fi
cd "$DIR" && echo "WordPress at http://localhost:$PORT  (admin / admin123)" && exec php -S "0.0.0.0:$PORT" -t .
