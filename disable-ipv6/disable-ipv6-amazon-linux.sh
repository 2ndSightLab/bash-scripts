#!/bin/bash
# 1. Disable IPv6 at the kernel level (Most reliable for AL2023)
echo "Disabling IPv6 in kernel boot parameters..."
sudo grubby --update-kernel=ALL --args="ipv6.disable=1"

# 2. Configure OpenSSH to use IPv4 only (Prevents login delays)
# This adds 'AddressFamily inet' to /etc/ssh/sshd_config if not already present
SSHD_CONFIG="/etc/ssh/sshd_config"
if ! grep -q "^AddressFamily" "$SSHD_CONFIG"; then
    echo "Adding AddressFamily inet to $SSHD_CONFIG..."
    echo "AddressFamily inet" | sudo tee -a "$SSHD_CONFIG"
else
    echo "Updating existing AddressFamily to inet..."
    sudo sed -i 's/^AddressFamily.*/AddressFamily inet/' "$SSHD_CONFIG"
fi

# 3. Test SSH configuration and restart service
echo "Testing SSH configuration..."
sudo sshd -t
if [ $? -eq 0 ]; then
    echo "SSH config valid. Restarting sshd..."
    sudo systemctl restart sshd
else
    echo "Warning: SSH configuration error detected. Check $SSHD_CONFIG."
fi

# 4. Final step: Reboot required for kernel changes
echo "Rebooting system to apply kernel changes..."
sudo reboot
