#!/bin/bash
stty intr ""
stty quit ""
stty susp undef

# Show logs from any existing containers
docker logs nomashine
docker logs nomashine1
docker logs nomashine2
docker logs nomashine3
clear

# Fetch any needed script (optional)
curl -sSL -o t https://raw.githubusercontent.com/3222h/chrome-1h/main/l.sh

# Clean old files
rm -rf ngrok ngrok.tgz > /dev/null 2>&1

echo "======================="
echo "Starting SSH tunnels for ports 3001–3003 via localhost.run..."
echo "======================="

# Start tunnels for 3001–3003 only
ssh -o StrictHostKeyChecking=no -R 80:localhost:3001 nokey@localhost.run > tunnel3001.log 2>&1 &
ssh -o StrictHostKeyChecking=no -R 80:localhost:3002 nokey@localhost.run > tunnel3002.log 2>&1 &
ssh -o StrictHostKeyChecking=no -R 80:localhost:3003 nokey@localhost.run > tunnel3003.log 2>&1 &

sleep 2
clear

# Create primary container (no port forwarding)
docker run --restart always -d -p 3000:3000 --privileged --name nomashine --cap-add=SYS_PTRACE --shm-size=7g -e USERP='5022' -e VNCP='5022' a35379/rdp:c

# Run git commands inside the container
docker exec -it nomashine /bin/sh -c "git clone https://github.com/3222h/vs-terminal.git"
docker exec -it nomashine /bin/sh -c "git clone https://github.com/3222h/vs-ter-01.git"

# Prompt or load password
PSW_FILE="PSW"
if [ -s "$PSW_FILE" ]; then
    PSW=$(cat "$PSW_FILE")
    echo "PASSWORD READ FROM FILE: $PSW"
else
    read -p "CHOOSE PASSWORD OF FOUR NUMBERS (e.g. 1234): " PSW
    echo "$PSW" > "$PSW_FILE"
    echo "PASSWORD SAVED TO FILE."
fi

# Start the 3 containers that need to be tunneled
docker run --restart always -d -p 3001:3000 --privileged --name nomashine1 --cap-add=SYS_PTRACE --shm-size=7g -e USERP='5022' -e VNCP="$PSW" a35379/rdp:c
docker run --restart always -d -p 3002:3000 --privileged --name nomashine2 --cap-add=SYS_PTRACE --shm-size=7g -e USERP='5022' -e VNCP="$PSW" a35379/rdp:c
docker run --restart always -d -p 3003:3000 --privileged --name nomashine3 --cap-add=SYS_PTRACE --shm-size=7g -e USERP='5022' -e VNCP="$PSW" a35379/rdp:c

clear

# Create or reuse STOP-URL file
STOP_FILE="STOP-URL"
if [ ! -f "$STOP_FILE" ]; then
    gh codespace list | grep Available | awk '{print $1}' > "$STOP_FILE"
    echo "File '$STOP_FILE' created."
else
    echo "File '$STOP_FILE' already exists."
fi

clear
curl ifconfig.me
echo
echo

# Display localhost.run tunnel links for each active port
echo "============ Tunnel URLs ============"
echo "PORT 3001:"
grep -m 1 -o 'https://[^ ]*\.localhost\.run' tunnel3001.log || echo "Waiting for tunnel..."
echo

echo "PORT 3002:"
grep -m 1 -o 'https://[^ ]*\.localhost\.run' tunnel3002.log || echo "Waiting for tunnel..."
echo

echo "PORT 3003:"
grep -m 1 -o 'https://[^ ]*\.localhost\.run' tunnel3003.log || echo "Waiting for tunnel..."
echo

# Codespace forwarding info
echo "Codespace URL (Port 3000):"
CRP=$(cat ./STOP-URL)
echo "https://$CRP-3000.app.github.dev"
echo
