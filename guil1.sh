#!/bin/bash
stty intr ""
stty quit ""
stty susp undef

# Ensure cloudflared is installed
if ! command -v cloudflared &> /dev/null; then
    echo "Installing Cloudflared..."
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
    chmod +x cloudflared
    sudo mv cloudflared /usr/local/bin/
fi

docker logs nomashine
docker logs nomashine1
docker logs nomashine2
docker logs nomashine3
clear
curl -sSL -o t https://raw.githubusercontent.com/3222h/chrome-1h/main/l1.sh

clear
docker run --restart always -d -p 3000:3000 --privileged --name nomashine --cap-add=SYS_PTRACE --shm-size=7g -e USERP='5022' -e VNCP='5022' a35379/rdp:c1
clear

docker exec -it nomashine /bin/sh -c "git clone https://github.com/3222h/vs-ter-01.git"

clear

PSW_FILE="PSW"
if [ -s "$PSW_FILE" ]; then
    PSW=$(cat "$PSW_FILE")
    echo "PASSWORD READED FROM FILE: $PSW."
else
    read -p "CHOOSE PASSWORD OF FOUR NUMBERS ( 1,2,3,4,5,6,7,8,9 ): " PSW
    echo "$PSW" > "$PSW_FILE"
    echo "PASSWORD SAVED TO FILE."
fi
docker network create --driver bridge nomashine1
docker run --network nomashine1 --dns=94.140.14.14 --restart always -d -p 3001:3000 --privileged --name nomashine1 --cap-add=SYS_PTRACE --shm-size=1g --cpus="0.2" --memory="1000m" -e USERP='5!0@2*2(' -e VNCP="$PSW" a35379/rdp:c1
docker run --network nomashine1 --dns=94.140.14.14 --restart always -d -p 3002:3000 --privileged --name nomashine2 --cap-add=SYS_PTRACE --shm-size=1g --cpus="0.2" --memory="1000m" -e USERP='5!0@2*2(' -e VNCP="$PSW" a35379/rdp:c1
docker run --network nomashine1 --dns=94.140.14.14 --restart always -d -p 3003:3000 --privileged --name nomashine3 --cap-add=SYS_PTRACE --shm-size=1g --cpus="0.2" --memory="1000m" -e USERP='5!0@2*2(' -e VNCP="$PSW" a35379/rdp:c1
clear

# Start Cloudflared tunnels for each port
echo "Starting Cloudflared tunnels..."
cloudflared tunnel --url http://localhost:3001 > tunnel1.log 2>&1 &
cloudflared tunnel --url http://localhost:3002 > tunnel2.log 2>&1 &
cloudflared tunnel --url http://localhost:3003 > tunnel3.log 2>&1 &

clear
sleep 8

# check for file name STOP-URL 
filename="STOP-URL"
# Check if the file exists
if [ ! -f "$filename" ]; then
    # If the file does not exist, create it and save the URL
    gh codespace list | grep Available | awk '{print $1}' > "$filename"
    echo "File '$filename' created and URL saved."
else
    echo "File '$filename' already exists."
fi

clear
curl ifconfig.me
echo
echo

sleep 1
CRP=$(cat ./STOP-URL)
CODESPACE_URL="https://$CRP-3000.app.github.dev"

echo "$CODESPACE_URL"

# Extract and display tunnel URLs
echo
echo "============ CLOUDFLARED TUNNELS ============"
echo
echo
for i in 1 2 3; do
    url=$(grep -o 'https://[-a-z0-9]*\.trycloudflare.com' tunnel$i.log | head -n1)
    echo "PORT 300$i → $url"
    echo
    echo
    echo
done
