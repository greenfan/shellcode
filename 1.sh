#!/usr/bin/env bash
# This script is automagically pulled down by Atlantis_startupBash1.sh -> /usr/local/sbin/start-ssh-tunnels.sh .... 
# Modify this script to add any bash sourcing or startup tasks for atlantis.
set -euo pipefail

APP_DIR="/mnt/Delta/Bash_Projects/10ngenius"
APP_PORT="5055"
APP_ACCESS_LOG="gunicorn_access.log"
APP_ERROR_LOG="gunicorn_error.log"

APP_CMD="gunicorn --bind 0.0.0.0:${APP_PORT} --access-logfile ${APP_ACCESS_LOG} --error-logfile ${APP_ERROR_LOG} app:app"

LOG_FILE="/tmp/Atlantis_StartupBash2.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $1" | tee -a "$LOG_FILE"
}

# add a better test… test if vnc can connect on 0.0.0.0:16969 if not, start on 5904 -> 0.0.0.0:19999
if ! ss -ltn | grep 5903 ; then
    echo "vnc not running on port 5903, initiating now on port 5904"
    screen -dm vncserver :4 -geometry 1420x720
    screen -dmt TUNNELVNC-5904  ssh -N -L 0.0.0.0:19999:localhost:5904 red@localhost
else
    echo "VNC appears to be running on port 5903, moving on"
fi


start_screen() {
    local session_name="$1"
    shift
    local cmd="$*"

    if screen -list | grep -q "\.${session_name}[[:space:]]"; then
        log "Screen session '${session_name}' is already running. Skipping."
    else
        log "Starting screen session '${session_name}'..."
        screen -dmS "$session_name" bash -c "$cmd"
    fi
}

# New function to start the screen session specifically as user 'red'

start_screen_red() {
    local session_name="$1"
    shift
    local cmd="$*"

    if screen -list | grep -q "\.${session_name}[[:space:]]"; then
        log "Screen session '${session_name}' is already running. Skipping."
    else
        log "Starting screen session '${session_name}' as user 'red'..."
	doas -u red screen -dmS "$session_name" bash -c "$cmd"
    fi
}

log "=== Atlantis Startup2 Part 3: SSH Tunnels ==="

command -v screen >/dev/null || { log "ERROR: screen not installed"; exit 1; }
command -v ssh >/dev/null || { log "ERROR: ssh not installed"; exit 1; }
command -v gunicorn >/dev/null || { log "ERROR: gunicorn not installed or not in PATH"; exit 1; }

start_screen "atlantis_ssh_11433" ssh -N -L 0.0.0.0:11433:localhost:11434 red@localhost
start_screen "atlantis_ssh_11111" ssh -N -L 0.0.0.0:11111:localhost:11434 red@localhost
start_screen "atlantis_ssh_51000" ssh -N -L 51000:localhost:3000 red@localhost

log "=== Atlantis Startup2 Part 4: 10ginus - starting 10nginus on port 5055 ==="

echo "=== Atlantis Startup2 Part 4: 10nginus - start listening on port 5055 ==="

log "=== Atlantis Startup2 Part 4: 10ginus - starting 10nginus on port 5055 ==="

log "=== Atlantis Startup2 Part 4: 10ginus - starting 10nginus on port 5055 ==="

echo "=== Atlantis Startup2 Part 4: 10nginus - start listening on port 5055 ==="

if [ ! -d "$APP_DIR" ]; then
    log "ERROR: App directory '$APP_DIR' does not exist!"
    exit 1
fi

if ss -tuln | grep -q ":${APP_PORT}[[:space:]]"; then
    log "Port ${APP_PORT} is already listening. Assuming app is already running."
else
    log "Launching Gunicorn as user 'red'..."
    # We use the full path to gunicorn and the red-user specific screen function
    GUNICORN_PATH="/home/red/.local/bin/gunicorn"
    FULL_APP_CMD="cd '$APP_DIR' && $GUNICORN_PATH --bind 0.0.0.0:${APP_PORT} --access-logfile ${APP_ACCESS_LOG} --error-logfile ${APP_ERROR_LOG} app:app"
    
    start_screen_red "atlantis_app_gunicorn" "$FULL_APP_CMD"

    sleep 5

    if ss -tuln | grep -q ":${APP_PORT}[[:space:]]"; then
        log "SUCCESS: Gunicorn is listening on port ${APP_PORT}."
    else
        log "ERROR: Gunicorn did not bind to port ${APP_PORT}."
        log "Check logs in: $APP_DIR/$APP_ERROR_LOG"
        exit 1
    fi
fi

log "=== Atlantis Startup2 Part 4 - 10ginus complete ==="
log "=== Atlantis Startup2 - Parts 1 through 4 complete  [ started and checked vnc, started SSH tunnels, started 10ginus ] ==="
echo "=== Atlantis Startup2 - Parts 1 through 4 complete [ started and checked vnc, started SSH tunnels, started 10ginus ] ==="


