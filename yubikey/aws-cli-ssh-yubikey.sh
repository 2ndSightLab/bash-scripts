#!/bin/bash

# Configuration
SECRET_ID="my/aws/iam/credentials"
REGION="us-east-1"

# Wrap entire logic in a subshell () to isolate variables from the environment
(
    # 1. Retrieve secret directly into memory (JSON format)
    # Uses instance role to fetch secret; results never touch a file
    SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ID" --region "$REGION" --query SecretString --output text)

    # 2. Extract credentials using jq
    AK=$(echo "$SECRET_JSON" | jq -r '.access_key')
    SK=$(echo "$SECRET_JSON" | jq -r '.secret_key')
    MFA_ARN=$(echo "$SECRET_JSON" | jq -r '.mfa_arn')

    # 3. Prompt for YubiKey touch using /dev/tty
    # This ensures the prompt is visible even if the script output is redirected
    echo "Please touch your YubiKey now..." > /dev/tty
    
    # Read the YubiKey OTP from /dev/tty (YubiKey types the code + Enter)
    read -r MFA_TOKEN < /dev/tty

    # 4. Get temporary credentials with MFA
    # We prefix variables to the command to avoid persistent env vars
    TEMP_CREDS=$(AWS_ACCESS_KEY_ID="$AK" AWS_SECRET_ACCESS_KEY="$SK" \
        aws sts get-session-token \
        --serial-number "$MFA_ARN" \
        --token-code "$MFA_TOKEN" \
        --region "$REGION" \
        --output json)

    # 5. Extract and use temporary credentials to run your final AWS command
    # This runs the target command (e.g., get-caller-identity) with the new MFA-authorized token
    AWS_ACCESS_KEY_ID=$(echo "$TEMP_CREDS" | jq -r '.Credentials.AccessKeyId') \
    AWS_SECRET_ACCESS_KEY=$(echo "$TEMP_CREDS" | jq -r '.Credentials.SecretAccessKey') \
    AWS_SESSION_TOKEN=$(echo "$TEMP_CREDS" | jq -r '.Credentials.SessionToken') \
    aws sts get-caller-identity --region "$REGION"

) # Subshell ends; AK, SK, and Tokens are cleared from memory
