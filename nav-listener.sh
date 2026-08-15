#!/usr/bin/env bash
set -u

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# One invocation per connection: read the forwarded direction and dispatch it.
IFS= read -r direction || exit 1
exec "$script_dir/mac-nav.sh" "$direction"
