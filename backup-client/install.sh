#!/bin/bash

cd "$(dirname "$0")" # cd to the directory of this script

# Detect sudo or fallback
run_cmd() {
  if command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    "$@"
  fi
}

install_or_update_unix() {
  if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet backrest; then
    run_cmd systemctl stop backrest
    echo "Paused backrest for update"
  fi
  install_unix
}

install_unix() {
  echo "Installing backrest to /usr/local/bin"
  run_cmd mkdir -p /usr/local/bin
  run_cmd cp "$(ls -1 backrest | head -n 1)" /usr/local/bin/backrest
}

create_systemd_service() {
  if [ ! -d /etc/systemd/system ]; then
    echo "Systemd not found. This script is only for systemd-based systems."
    exit 1
  fi

  if [ -f /etc/systemd/system/backrest.service ]; then
    echo "Systemd unit already exists. Skipping creation."
    return 0
  fi

  echo "Creating systemd service at /etc/systemd/system/backrest.service"

  run_cmd tee /etc/systemd/system/backrest.service > /dev/null <<- EOM
[Unit]
Description=Backrest Service
After=network.target

[Service]
Type=simple
User=$(whoami)
Group=$(whoami)
ExecStart=/usr/local/bin/backrest
Environment="BACKREST_PORT=127.0.0.1:9898"

[Install]
WantedBy=multi-user.target
EOM

  echo "Reloading systemd daemon"
  run_cmd systemctl daemon-reload
}

create_launchd_plist() {
  echo "Creating launchd plist at /Library/LaunchAgents/com.backrest.plist"

  run_cmd tee /Library/LaunchAgents/com.backrest.plist > /dev/null <<- EOM
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.backrest</string>
    <key>ProgramArguments</key>
    <array>
    <string>/usr/local/bin/backrest</string>
    </array>
    <key>KeepAlive</key>
    <true/>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
        <key>BACKREST_PORT</key>
        <string>127.0.0.1:9898</string>
    </dict>
</dict>
</plist>
EOM
}

enable_launchd_plist() {
  echo "Trying to unload any previous version of com.backrest.plist"
  launchctl unload /Library/LaunchAgents/com.backrest.plist || true
  echo "Loading com.backrest.plist"
  launchctl load -w /Library/LaunchAgents/com.backrest.plist
}

create_rcd_service() {
  echo "Creating rc.d service for FreeBSD"
  local rcd_path="/usr/local/etc/rc.d/backrest"
  echo "Creating rc.d service at $rcd_path"

  run_cmd tee "$rcd_path" > /dev/null << 'EOM'
#!/bin/sh

# PROVIDE: backrest
# REQUIRE: NETWORKING
# KEYWORD: shutdown

. /etc/rc.subr

name="backrest"
rcvar=backrest_enable
pidfile="/var/run/${name}.pid"
command="/usr/local/bin/backrest"
command_args="-bind-address 0.0.0.0:9898"
log_file="/var/log/backrest.log"
required_files="${command}"

load_rc_config $name
: ${backrest_enable:="NO"}

start_cmd="${name}_start"
stop_cmd="${name}_stop"
status_cmd="${name}_status"

backrest_start() {
    /usr/sbin/daemon -f -p ${pidfile} ${command} ${command_args} >> ${log_file}
}

backrest_stop() {
    if [ -f ${pidfile} ]; then
        kill $(cat ${pidfile}) && rm -f ${pidfile}
    else
        echo "PID file não encontrado: ${pidfile}"
    fi
}

backrest_status() {
    if [ -f ${pidfile} ]; then
        if ps -p $(cat ${pidfile}) > /dev/null 2>&1; then
            echo "${name} está em execução (PID $(cat ${pidfile}))"
            return 0
        else
            echo "${name} não está em execução, mas o PID file existe."
            return 1
        fi
    else
        echo "${name} não está em execução."
        return 1
    fi
}

load_rc_config $name
run_rc_command "$1"
EOM

  run_cmd chmod +x "$rcd_path"
  run_cmd sysrc backrest_enable=YES
  echo "Starting backrest rc.d service"
  run_cmd service backrest start
}

OS=$(uname -s)
if [ "$OS" = "Darwin" ]; then
  echo "Installing on Darwin"
  install_unix
  create_launchd_plist
  enable_launchd_plist
  run_cmd xattr -d com.apple.quarantine /usr/local/bin/backrest # remove quarantine flag
elif [ "$OS" = "Linux" ]; then
  echo "Installing on Linux"
  install_or_update_unix
  create_systemd_service
  echo "Enabling systemd service backrest.service"
  run_cmd systemctl enable backrest
  run_cmd systemctl start backrest
elif [ "$OS" = "FreeBSD" ]; then
  echo "Installing on FreeBSD"
  install_unix
  create_rcd_service
else
  echo "Unknown OS: $OS. This script only supports Darwin, Linux, and FreeBSD."
  exit 1
fi

echo "Logs are available at ~/.local/share/backrest/processlogs/backrest.log"
echo "Access backrest WebUI at http://localhost:9898"
