#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"

mkdir -p "$ROOT/Vault/Areas" "$ROOT/Vault/Projects" "$ROOT/Vault/Domains"

cat > "$ROOT/Vault/Core.md" << 'EOF'
test

[Ir a YourArea](./Areas/YourArea.md)
EOF

cat > "$ROOT/Vault/Areas/YourArea.md" << 'EOF'
test

[Ir a YourDomain](../Domains/YourDomain.md)
EOF

cat > "$ROOT/Vault/Domains/YourDomain.md" << 'EOF'
test

[Ir a YourProject](../Projects/YourProject.md)
EOF

# Crear (o vaciar) Projects/YourProject.md sin contenido
: > "$ROOT/Vault/Projects/YourProject.md"

echo "Estructura creada en: $ROOT/Vault"
