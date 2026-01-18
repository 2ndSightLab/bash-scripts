(
    # 1. Fetch the OTP seed from Secrets Manager (stored in subshell memory)
    otp_seed=$(aws secretsmanager get-secret-value --secret-id "MyOTPSeed" --query SecretString --output text)

    # 2. Capture Yubikey button click (HOTP mode) via /dev/tty
    echo "Please touch your Yubikey now..." > /dev/tty
    read -s -r hotp_from_device < /dev/tty

    # 3. Generate TOTP using Piped Stdin (No Heredoc, No Export)
    totp_code=$(echo "$otp_seed" | python3 -c "import pyotp, sys; print(pyotp.TOTP(sys.stdin.read().strip()).now())")

    # 4. Fetch Dev Credentials from Secrets Manager (JSON format expected)
    # Parse the Access Key and Secret Key using jq
    dev_creds=$(aws secretsmanager get-secret-value --secret-id "DevCredentials" --query SecretString --output text)
    akid=$(echo "$dev_creds" | jq -r .AccessKeyId)
    sak=$(echo "$dev_creds" | jq -r .SecretAccessKey)

    # 5. Execute AWS command using direct Environment Injection
    # This prevents the credentials from being 'exported' to the shell session
    AWS_ACCESS_KEY_ID="$akid" \
    AWS_SECRET_ACCESS_KEY="$sak" \
    aws s3 ls --profile "mfa-profile" --token "$totp_code"

    # End of subshell: All memory variables (seed, keys, codes) are purged
)
