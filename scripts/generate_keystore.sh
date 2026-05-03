#!/bin/bash
set -e

# Usage: ./scripts/generate_keystore.sh
# This script generates a keystore for Android release builds and writes a key.properties file.
# It will prompt for values; do NOT commit android/key.properties or the keystore to version control.

KEYSTORE_DIR="android/keystore"
KEYSTORE_FILE="$KEYSTORE_DIR/release-key.jks"
KEYPROPS_FILE="android/key.properties"

mkdir -p "$KEYSTORE_DIR"

read -p "Enter keystore password (will not be echoed): " -s STORE_PASS
echo
read -p "Enter key password (can be same as keystore password): " -s KEY_PASS
echo
read -p "Enter key alias (e.g. release-key): " KEY_ALIAS
if [ -z "$KEY_ALIAS" ]; then
  KEY_ALIAS=release-key
fi
read -p "Enter your name/organizational unit (CN) [Your Name]: " CN
if [ -z "$CN" ]; then
  CN="Your Name"
fi

# Generate keystore
keytool -genkeypair \
  -alias "$KEY_ALIAS" \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -keystore "$KEYSTORE_FILE" \
  -storepass "$STORE_PASS" \
  -keypass "$KEY_PASS" \
  -dname "CN=$CN, OU=Unknown, O=Unknown, L=Unknown, S=Unknown, C=US"

# Write key.properties (do NOT commit this file)
cat > "$KEYPROPS_FILE" <<EOF
storePassword=$STORE_PASS
keyPassword=$KEY_PASS
keyAlias=$KEY_ALIAS
storeFile=keystore/release-key.jks
EOF

echo "Keystore generated at $KEYSTORE_FILE"
echo "Wrote helper file $KEYPROPS_FILE (DO NOT COMMIT)"

echo "Next: add android/key.properties to .gitignore (already added) and run:\n  flutter build appbundle --release"
