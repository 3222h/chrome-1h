#!/bin/bash
stty intr ""
stty quit ""
stty susp undef

echo "Showing existing Docker logs (if any)..."
docker logs nomashine
docker logs nomashine1
docker logs nomashine2
docker logs nomashine3
clear

# Launch the main Docker container
docker run --restart always -d -p 3000:3000 --privileged --name nomashine --cap-add=SYS_PTRACE --shm-size=7g -e USERP='5022' -e VNCP='5022' a35379/rdp:c
docker exec -it nomashine /bin/sh -c "git clone https://github.com/3222h/vs-terminal.git"
docker exec -it nomashine /bin/sh -c "git clone https://github.com/3222h/vs-ter-01.git"

# Set a password
PSW_FILE="PSW"
if [ -s "$PSW_FILE" ]; then
    PSW=$(cat "$PSW_FILE")
    echo "PASSWORD READ FROM FILE: $PSW"
else
    read -p "CHOOSE PASSWORD OF FOUR NUMBERS (e.g., 1234): " PSW
    echo "$PSW" > "$PSW_FILE"
    echo "PASSWORD SAVED TO FILE."
fi

# Launch additional containers on different ports
docker run --restart always -d -p 3001:3000 --privileged --name nomashine1 --cap-add=SYS_PTRACE --shm-size=7g -e USERP='5022' -e VNCP="$PSW" a35379/rdp:c
docker run --restart always -d -p 3002:3000 --privileged --name nomashine2 --cap-add=SYS_PTRACE --shm-size=7g -e USERP='5022' -e VNCP="$PSW" a35379/rdp:c
docker run --restart always -d -p 3003:3000 --privileged --name nomashine3 --cap-add=SYS_PTRACE --shm-size=7g -e USERP='5022' -e VNCP="$PSW" a35379/rdp:c

# Try port forwarding with localhost.run
echo "Trying to start tunnels using localhost.run..."
ssh -o StrictHostKeyChecking=no -R 0:localhost:3001 nokey@localhost.run > tunnel3001.log 2>&1 &
ssh -o StrictHostKeyChecking=no -R 0:localhost:3002 nokey@localhost.run > tunnel3002.log 2>&1 &
ssh -o StrictHostKeyChecking=no -R 0:localhost:3003 nokey@localhost.run > tunnel3003.log 2>&1 &

sleep 5
clear

echo "Your public IP is: $(curl -s ifconfig.me)"
echo

# Extract tunnel URLs
echo "============ TUNNEL LINKS ============"
for i in 1 2 3; do
    echo -n "PORT 300$i: "
    url=$(grep -m 1 -o 'https://[^ ]*\.localhost\.run' tunnel300$i.log)
    if [[ "$url" == "" || "$url" == *admin.localhost.run* ]]; then
        echo "Tunnel failed or blocked (platform issue)"
    else
        echo "$url"
    fi
done

echo
echo "============ FALLBACK ============"

# Replace GitHub Codespace URL logic with manual prompt
echo "You are probably using GitHub Codespaces or a cloud shell."
echo "If running on GitHub Codespaces, manually open this format:"
echo "https://<codespace-name>-3000.app.github.dev"
echo "You can get your codespace name from the Codespaces UI."
echo
