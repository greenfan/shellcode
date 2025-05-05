#!/bin/bash

# --- Save Current iptables Rules with Unique Date-Based Filename ---
CURRENT_DATE=$(date +"%Y-%m-%d_%H-%M-%S")
SAVE_FILE="/etc/iptables/rules_backup_$CURRENT_DATE"
echo "Saving current iptables rules to $SAVE_FILE..."
iptables-save > "$SAVE_FILE"
if [ $? -eq 0 ]; then
    echo "Backup successful."
else
    echo "Backup failed. Exiting..."
    exit 1
fi

# --- Define Variables for LAN and Exclusion Subnets ---
LAN_SUBNET="10.2.0.0/16"               # Your LAN subnet
MGMT_IP="YOUR_MANAGEMENT_IP"            # Your specific management IP if needed outside LAN
ALLOWED_SUBNETS=(
    "A.98.97.175.0/24"                 # First allowed subnet (placeholder)
    "A.98.97.173.0/24"                 # Second allowed subnet (placeholder)
    "98.0.0.0/8"                       # New allowed subnet
    # Add more subnets here as needed
)

# --- Fetch Current Public IP with Retry Mechanism ---
echo "Fetching current public IP using curl..."
MAX_RETRIES=3
RETRY_COUNT=0
PUBLIC_IP=""

while [ -z "$PUBLIC_IP" ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    PUBLIC_IP=$(curl -s https://icanhazip.com)
    if [ -n "$PUBLIC_IP" ]; then
        echo "Public IP successfully fetched: $PUBLIC_IP. Adding to exclusion list."
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo "Attempt $RETRY_COUNT/$MAX_RETRIES failed to fetch public IP. Retrying..."
        sleep 2
    fi
done

if [ -z "$PUBLIC_IP" ]; then
    echo "Failed to fetch public IP after $MAX_RETRIES attempts. Proceeding without it."
else
    echo "Public IP confirmed and stored in variable: $PUBLIC_IP"
fi

# --- Extract currently connected SSH client IPs and convert to Class C subnets ---
echo "Detecting currently connected SSH clients..."
# Using netstat or ss to get SSH connections (prefer ss if available)
SSH_CLIENT_SUBNETS=()
if command -v ss &> /dev/null; then
    # Get established SSH connections, extract remote IPs, convert to Class C subnets
    CONNECTED_SSH_IPS=$(ss -tn state established '( dport = :22 or sport = :22 )' | awk 'NR>1 {split($5, a, ":"); print a[1]}')
elif command -v netstat &> /dev/null; then
    # Alternative using netstat if ss is not available
    CONNECTED_SSH_IPS=$(netstat -tn | grep ":22" | grep "ESTABLISHED" | awk '{split($5, a, ":"); print a[1]}')
else
    echo "Warning: Neither ss nor netstat is available. Cannot detect SSH client IPs."
    CONNECTED_SSH_IPS=""
fi

# Convert IPs to Class C subnets (/24) and add to array
if [ -n "$CONNECTED_SSH_IPS" ]; then
    for IP in $CONNECTED_SSH_IPS; do
        # Convert IP to Class C subnet by replacing last octet with 0/24
        CLASS_C_SUBNET=$(echo "$IP" | sed -E 's/([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+/\1.0\/24/')
        # Check if this subnet is already in our list to avoid duplicates
        if [[ ! " ${SSH_CLIENT_SUBNETS[@]} " =~ " ${CLASS_C_SUBNET} " ]]; then
            SSH_CLIENT_SUBNETS+=("$CLASS_C_SUBNET")
            echo "Detected SSH client subnet: $CLASS_C_SUBNET"
        fi
    done
else
    echo "No active SSH connections detected or failed to parse connections."
fi

echo "Preparing new iptables rules..."

# Create a temporary configuration to display and apply if confirmed
TEMP_CONFIG=$(mktemp)

# Start with a clean slate in our temporary rules
# We're not applying these yet, just preparing them
cat > "$TEMP_CONFIG" << EOF
# Flush all chains
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-F INPUT
-F FORWARD
-F OUTPUT

# Allow loopback
-A INPUT -i lo -j ACCEPT
-A OUTPUT -o lo -j ACCEPT

# Allow established and related connections
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow LAN subnet
-A INPUT -s $LAN_SUBNET -j ACCEPT

# Allow explicitly defined subnets
EOF

# Add the specific allowed subnets to the config
for subnet in "${ALLOWED_SUBNETS[@]}"; do
    echo "-A INPUT -s $subnet -j ACCEPT" >> "$TEMP_CONFIG"
done

# Add public IP if fetched
if [ -n "$PUBLIC_IP" ]; then
    echo "-A INPUT -s $PUBLIC_IP -j ACCEPT" >> "$TEMP_CONFIG"
fi

# Add SSH client subnets
for ssh_subnet in "${SSH_CLIENT_SUBNETS[@]}"; do
    echo "-A INPUT -s $ssh_subnet -j ACCEPT" >> "$TEMP_CONFIG"
done

# Finalize the config
echo "COMMIT" >> "$TEMP_CONFIG"

# --- Display the proposed rules to the user ---
echo -e "\n===================================================="
echo "PROPOSED IPTABLES RULES (PREVIEW BEFORE APPLYING):"
echo "===================================================="
echo -e "\nThe following rules will be applied if confirmed:"
echo -e "\n*** PROPOSED RULES SUMMARY ***"
echo "===================================================="
echo "Default Policies:"
echo "  INPUT: DROP"
echo "  FORWARD: DROP"
echo "  OUTPUT: ACCEPT"
echo -e "\nAllowed Traffic:"
echo "  - Loopback interface (localhost)"
echo "  - Established/Related connections"
echo "  - LAN Subnet: $LAN_SUBNET"

echo -e "\nExplicitly Allowed Subnets:"
for subnet in "${ALLOWED_SUBNETS[@]}"; do
    echo "  - $subnet"
done

if [ -n "$PUBLIC_IP" ]; then
    echo -e "\nCurrent Public IP:"
    echo "  - $PUBLIC_IP"
fi

if [ ${#SSH_CLIENT_SUBNETS[@]} -gt 0 ]; then
    echo -e "\nDetected SSH Client Subnets:"
    for ssh_subnet in "${SSH_CLIENT_SUBNETS[@]}"; do
        echo "  - $ssh_subnet"
    done
else
    echo -e "\nNo SSH client subnets detected."
fi

echo -e "\nDetailed iptables Rules:"
echo "===================================================="
cat "$TEMP_CONFIG"
echo "===================================================="

# Ask for confirmation before applying
echo -e "\nWARNING: Applying these rules will replace your current iptables configuration."
echo "If you are connecting remotely, ensure your connection source is included in the allowed subnets."
echo -e "\nA backup of your current rules has been saved to: $SAVE_FILE"
echo -e "You can restore it with: iptables-restore < $SAVE_FILE\n"

read -p "Review the rules above. Apply these rules? (y/N): " CONFIRM
if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Applying new iptables rules..."
    
    # Actually apply the rules now
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
    
    # Set default policies
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT

    # Allow loopback
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT

    # Allow established/related connections
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

    # Allow LAN subnet
    iptables -A INPUT -s "$LAN_SUBNET" -j ACCEPT

    # Allow explicitly defined subnets
    for subnet in "${ALLOWED_SUBNETS[@]}"; do
        echo "Allowing traffic from subnet: $subnet"
        iptables -A INPUT -s "$subnet" -j ACCEPT
    done

    # Allow public IP
    if [ -n "$PUBLIC_IP" ]; then
        echo "Allowing traffic from public IP: $PUBLIC_IP"
        iptables -A INPUT -s "$PUBLIC_IP" -j ACCEPT
    fi

    # Allow SSH client subnets
    for ssh_subnet in "${SSH_CLIENT_SUBNETS[@]}"; do
        echo "Allowing traffic from SSH client subnet: $ssh_subnet"
        iptables -A INPUT -s "$ssh_subnet" -j ACCEPT
    done

    echo "New rules applied successfully."

    # Display a summary of the current iptables rules
    echo -e "\nCurrent iptables Rules Summary:"
    echo "================================"
    iptables -L -v -n --line-numbers
    echo "================================"
    echo "Summary complete. Review the rules above for verification."
else
    echo "Operation cancelled. No changes were made to your iptables configuration."
    echo "Your current rules remain in effect."
fi

# Clean up temporary file
rm -f "$TEMP_CONFIG"