#!/bin/bash

# Execute within a subshell to isolate environment
(
    # 1. Fetch JSON from Secrets Manager using EC2 Role
    SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id "YourSecretID" --query 'SecretString' --output text 2>/dev/null)
    
    # 2. Parse the specific "SHARED_SECRET" key (e.g. "JBSWY3DPEHPK3PXP")
    S_SEC=$(echo "$SECRET_VALUE" | jq -r '.SHARED_SECRET // .')

    # 3. Use /dev/tty to detect button push
    echo "Press any key to generate code..."
    read -n 1 -s < /dev/tty

    # 4. TOTP Logic (Counter calculation)
    T_STEP=30
    T_CTR=$(($(date +%s) / T_STEP))
    H_CTR=$(printf '%016x' "$T_CTR")

    # 5. Perform HMAC-SHA1
    # FIX: Convert the Base32 secret to HEX first. 
    # OpenSSL's 'hexkey' option avoids the "binary in string" shell limitation.
    S_HEX=$(echo -n "$S_SEC" | base32 -d | xxd -p -c 256)
    
    H_HEX=$(echo -n "$H_CTR" | xxd -r -p | openssl dgst -sha1 -mac HMAC -macopt "hexkey:$S_HEX" | awk '{print $NF}')

    # 6. Dynamic Truncation for 6-digit code
    OFF=$(( 16#${H_HEX: -1} ))
    RAW=$(( (16#${H_HEX:$((OFF*2)):8} & 0x7FFFFFFF) % 1000000 ))
    CODE=$(printf "%06d" "$RAW")

    echo -e "\rTOTP_CODE: $CODE"
)
