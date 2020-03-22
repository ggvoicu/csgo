#!/usr/bin/env bash

# These envvars should've been set by the Dockerfile
# If they're not set then something went wrong during the build
: ${STEAM_DIR:?"ERROR: STEAM_DIR IS NOT SET!"}
: ${STEAMCMD_DIR:?"ERROR: STEAMCMD_DIR IS NOT SET!"}
: ${CSGO_APP_ID:?"ERROR: CSGO_APP_ID IS NOT SET!"}
: ${CSGO_DIR:?"ERROR: CSGO_DIR IS NOT SET!"}

export SERVER_HOSTNAME="${SERVER_HOSTNAME:-Counter-Strike: Global Offensive Dedicated Server}"
export SERVER_PASSWORD="${SERVER_PASSWORD:-}"
export RCON_PASSWORD="${RCON_PASSWORD:-changeme}"
export STEAM_ACCOUNT="${STEAM_ACCOUNT:-changeme}"
export IP="${IP:-0.0.0.0}"
export PORT="${PORT:-27015}"
export TV_PORT="${TV_PORT:-27020}"
export TICKRATE="${TICKRATE:-128}"
export FPS_MAX="${FPS_MAX:-300}"
export GAME_TYPE="${GAME_TYPE:-0}"
export GAME_MODE="${GAME_MODE:-1}"
export MAP="${MAP:-de_dust2}"
export MAPGROUP="${MAPGROUP:-mg_active}"
export MAXPLAYERS="${MAXPLAYERS:-12}"
export TV_ENABLE="${TV_ENABLE:-1}"
export LAN="${LAN:-0}"
export SOURCEMOD_ADMINS="${SOURCEMOD_ADMINS:-}"
export AUTHKEYWORKSHOP="${AUTHKEY:-}"

# Attempt to update CSGO before starting the server
${STEAMCMD_DIR}/steamcmd.sh +login anonymous +force_install_dir ${CSGO_DIR} +app_update ${CSGO_APP_ID} +quit

# Add steam ids to sourcemod admin file
IFS=',' read -ra STEAMIDS <<< "$SOURCEMOD_ADMINS"
for id in "${STEAMIDS[@]}"; do
    echo "\"$id\" \"99:z\"" >> $CSGO_DIR/csgo/addons/sourcemod/configs/admins_simple.ini
done

# Start the server
exec $BASH ${CSGO_DIR}/srcds_run \
        -console \
        -usercon \
        -game csgo \
        -autoupdate \
        -steam_dir $STEAMCMD_DIR \
        -steamcmd_script $STEAM_DIR/autoupdate_script.txt \
        -tickrate $TICKRATE \
        -port $PORT \
        -tv_port $TV_PORT \
        -net_port_try 1 \
        -ip $IP \
        -maxplayers_override $MAXPLAYERS \
        +fps_max $FPS_MAX \
        +game_type $GAME_TYPE \
        +game_mode $GAME_MODE \
        +mapgroup $MAPGROUP \
        +map $MAP \
        +sv_setsteamaccount $STEAM_ACCOUNT \
        +sv_lan $LAN
        -authkey $AUTHKEY
