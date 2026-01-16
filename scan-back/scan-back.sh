!/bin/bash
# Recommend excluding local host 127.0.0.1, your own IPs, and any internal IPs you should not be scanning
# On aws 169.254.169.254, 169.254.169.253, etc.

# Kill all background jobs started by this script on exit
trap 'echo "Cleaning up..."; kill $(jobs -p) 2>/dev/null; exit' INT TERM EXIT

# --- 1. CONFIGURATION & DIRECTORIES ---
MY_IP=$(hostname -I | awk '{print $1}')
LOG_DIR="/tmp/network_scans"
MASTER_LOG="$LOG_DIR/master_monitor.log"
NOT_IPS=""
NOT_PORTS=""

# LOG MANAGEMENT SETTINGS
MAX_USAGE_PERCENT=90      # Trigger action when disk is 90% full
LOG_POLICY="PURGE"       # Options: "PURGE" (delete old) or "STOP" (exit script)

mkdir -p "$LOG_DIR"
touch "$MASTER_LOG"

# --- 2. THE TOTAL CAPTURE FIX ---
exec &> >(tee -a "$MASTER_LOG")

echo "--- Network Monitor (v2026) ---"
echo "Policy: $LOG_POLICY if disk > $MAX_USAGE_PERCENT%"

# --- 3. PROMPTS ---
read -p "Exclude localhost (127.0.0.1)? [y/N]: " EX_LOCAL < /dev/tty
[[ "$EX_LOCAL" =~ ^[yY] ]] && NOT_IPS="127.0.0.1"

read -p "Exclude additional IPs (space-separated): " ADD_IPS < /dev/tty
NOT_IPS="$NOT_IPS $ADD_IPS"

read -p "Exclude additional PORTS (space-separated): " ADD_PORTS < /dev/tty
NOT_PORTS="$NOT_PORTS $ADD_PORTS"

read -p "Verbose? (y/n): " VERBOSE < /dev/tty
if [ "$VERBOSE" == "y" ]; then
   VERBOSE="-vvv -X"
fi

# --- 4. DEDUPLICATION & FILTER FIX ---
NOT_IPS_LIST=$(echo $NOT_IPS | tr ' ' '\n' | sort -u | grep -v '^$')
NOT_IPS_COMMA=$(echo "$NOT_IPS_LIST" | paste -sd ',' -)
NOT_PORTS_COMMA=$(echo $NOT_PORTS | tr ' ' '\n' | sort -nu | paste -sd ',' - | sed 's/^,//')

FILTER="$FILTER and not arp"

for ip in $NOT_IPS_LIST; do FILTER="$FILTER and not host $ip"; done
for port in $NOT_PORTS; do FILTER="$FILTER and not port $port"; done

# Remove that first leading " and "
FILTER="${FILTER# and }"

# --- 5. DISK SPACE CHECK FUNCTION ---
check_disk_space() {
    CURRENT_USAGE=$(df "$LOG_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$CURRENT_USAGE" -gt "$MAX_USAGE_PERCENT" ]; then
        if [ "$LOG_POLICY" == "STOP" ]; then
            echo "[$(date)] DISK CRITICAL ($CURRENT_USAGE%): Stopping capture."
            exit 1
        elif [ "$LOG_POLICY" == "PURGE" ]; then
            echo "[$(date)] DISK WARNING ($CURRENT_USAGE%): Purging oldest 10 logs."
            echo "Delete 10 oldest specific scan logs, leave master log"
            ls -tr "$LOG_DIR"/scan_*.log 2 | head -n 10 | xargs -r rm
        fi
    fi
}

echo "Running: sudo tcpdump -i any $VERBOSE -nn -l --immediate-mode \"$FILTER\""
sudo tcpdump -i any $VERBOSE -nn -l -Q in --immediate-mode "$FILTER" 2>&1 | \
while read -r line; do
    # Periodic disk check
    check_disk_space

    echo "$line"

    #skip liens with no ips
    [[ "$line" != *" > "* ]]  && continue

    #remove spaces
    RAW_SOURCE=$(echo "$line" | sed 's/ >.*//; s/.* //')

    if [[ "$REMOTE_IP" == *"."* ]]; then
        REMOTE_IP=$(echo "$RAW_SOURCE" | cut -d '.' -f 1-4)
        NMAP_FLAGS="-Pn -T4 -n"
    else
        REMOTE_IP="${RAW_SOURCE%.*}"
        NMAP_FLAGS="-6 -Pn -T4 -n"
    fi

    echo "REMOTE_IP: $REMOTE_IP"

    SPECIFIC_LOG="$LOG_DIR/scan_${REMOTE_IP}.log"

    if [[ -n $REMOTE_IP ]]; then

      if [ ! -f "$SPECIFIC_LOG" ]; then
            echo "[$(date)] ALERT: Incoming from $REMOTE_IP -> Scanning..."

            [[ -n "$NOT_IPS_COMMA" ]] && EX_FLAGS="$EX_FLAGS --exclude $NOT_IPS_COMMA"
            [[ -n "$NOT_PORTS_COMMA" ]] && EX_FLAGS="$EX_FLAGS --exclude-ports $NOT_PORTS_COMMA"

            # 6. SCAN LOGIC
            {
                echo "$line" 
                echo "--- Scan Report for $REMOTE_IP ---"
                echo "Start: $(datei)"
                echo "nmap $NMAP_FLAGS --open $EX_FLAGS \"$REMOTE_IP\""
                nmap $NMAP_FLAGS --open $EX_FLAGS "$REMOTE_IP"
                echo "Finish: $(date)"
                dig -x $REMOTE_IP
      } > "$SPECIFIC_LOG" 2>&1 &
      else
           echo "Log line to $SPECIFIC_LOG"
           echo "$line" >> "$SPECIFIC_LOG"
      fi

    else
        echo "Remote IP not set from $RAW_SOURCE"
    fi

done


