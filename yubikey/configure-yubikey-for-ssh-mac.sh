#!/bin/bash

# Configuration
REMOTE_USER="your_username"
REMOTE_HOST="your_server_ip"
KEY_PATH="$HOME/.ssh/id_yubikey_temp"

echo "1. Please insert your YubiKey..."
# Generate FIDO2 resident key. Private key is stored on hardware.
# -O resident: Stores the key on the YubiKey
# -O verify-required: Forces PIN entry for extra security
ssh-keygen -t ed25519-sk -O resident -O verify-required -f "$KEY_PATH" -C "yubikey-resident-key"

echo "2. Copying public key to remote host..."
ssh-copy-id -i "${KEY_PATH}.pub" "${REMOTE_USER}@${REMOTE_HOST}"

echo "3. Securing local environment..."
# Remove the local private key stub and public key file.
# The key now exists ONLY on the YubiKey hardware.
rm "$KEY_PATH" "${KEY_PATH}.pub"

echo "Setup Complete. No private keys are stored on this laptop."
