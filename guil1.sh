#!/bin/bash
stty intr ""
stty quit ""
stty susp undef

# Show existing Docker logs (optional)
docker logs nomashine
docker logs nomashine1
docker logs nomashine2
docker logs nomashine3
clear

# Optional: download external script
curl -sSL -o t https://raw.githubusercontent.com/3222h/chrome-1h/main/l.sh

# Start Docker containers
docker run --restart always -d -p 3000:3000 --privileged --name nomashine --cap-add=SYS_PTRACE --shm-size=7g -e USERP='5022' -e VNCP='5022' a35379/rdp:c
docker exec -it nomashine /bin/sh -c "git clone https://github.com/3222h/vs-terminal.git"
docker exec -it nomashine /bin/sh -c "git clone https://github.com/3222h/vs-ter-01.git"

# Set up password
PSW_FILE="PSW"
if [ -s "$PSW_FILE" ]; then
    PSW=$(cat "$PSW_FILE")
    echo "PASSWORD READ FROM FILE: $PSW"
else
    read -p "CHOOSE PASSWORD OF FOUR NUMBERS (e.g., 1234): " PSW
    echo "$PSW" > "$PSW_FILE"
    echo "PASSWORD SAVED TO FILE."
fi

# Start 3 additional containers
docker run --restart always -d -p 3001:3000 --privileged --name nomashine1 --cap-add=SYS_PTRACE --shm-size=7g -e USERP='5022' -e VNCP="$PSW" a35379/rdp:c
docker run --restart always -d -p 3002:3000 --privileged --name nomashine2 --cap-add=SYS_PTRACE --shm-size=7g -e USERP='5022' -e VNCP="$PSW" a35379/rdp:c
docker run --restart always -d -p 3003:3000 --privileged --name nomashine3 --cap-add=SYS_PTRACE --shm-size=7g -e USERP='5022' -e VNCP="$PSW" a35379/rdp:c

# Forward ports 3001, 3002, 3003 using localhost.run with random public port
echo "Creating localhost.run tunnels..."
ssh -o StrictHostKeyChecking=no -R 0:localhost:3001 nokey@localhost.run > tunnel3001.log 2>&1 &
ssh -o StrictHostKeyChecking=no -R 0:localhost:3002 nokey@localhost.run > tunnel3002.log 2>&1 &
ssh -o StrictHostKeyChecking=no -R 0:localhost:3003 nokey@localhost.run > tunnel3003.log 2>&1 &

# Wait for tunnels to initialize
sleep 5
clear

# Show public IP
echo "Your public IP is: $(curl -s ifconfig.me)"
echo

# Show localhost.run URLs
echo "============ TUNNEL LINKS ============"
echo -n "PORT 3001: "
grep -m 1 -o 'https://[^ ]*\.localhost\.run' tunnel3001.log || echo "Not ready"
echo

echo -n "PORT 3002: "
grep -m 1 -o 'https://[^ ]*\.localhost\.run' tunnel3002.log || echo "Not ready"
echo

echo -n "PORT 3003: "
grep -m 1 -o 'https://[^ ]*\.localhost\.run' tunnel3003.log || echo "Not ready"
echo

# Codespace fallback URL for 3000
STOP_FILE="STOP-URL"
if [ ! -f "$STOP_FILE" ]; then
    gh codespace list | grep Available | awk '{print $1}' > "$STOP_FILE"
    echo "File '$STOP_FILE' created."
fi

CRP=$(cat ./STOP-URL)
echo
echo "Codespace Port 3000 URL:"
echo "https://$CRP-3000.app.github.dev"
echo
