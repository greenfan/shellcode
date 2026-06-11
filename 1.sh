#!/usr/bin/env bash
# This script is automagically pulled down by Atlantis_startupBash1.sh -> /usr/local/sbin/start-ssh-tunnels.sh .... 
# Modify this script to add any bash sourcing or startup tasks for atlantis.
APP_PORT="5055"
APP_ACCESS_LOG="gunicorn_access.log"
APP_ERROR_LOG="gunicorn_error.log"

APP_CMD="gunicorn --bind 0.0.0.0:${APP_PORT} --access-logfile ${APP_ACCESS_LOG} --error-logfile ${APP_ERROR_LOG} app:app"

LOG_FILE="/tmp/Atlantis_StartupBash2.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $1" | tee -a "$LOG_FILE"
