#!/bin/bash
stty intr ""
stty quit ""
stty susp undef



docker logs nomashine
docker logs nomashine1
docker logs nomashine2
clear

rm -rf ngrok ngrok.tgz > /dev/null 2>&1
echo "======================="
echo "Downloading ngrok..."
echo "======================="
wget -O ngrok.tgz https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz > /dev/null 2>&1
tar -xvzf ngrok.tgz > /dev/null 2>&1


function goto
{
    label=$1
    cd 
    cmd=$(sed -n "/^:[[:blank:]][[:blank:]]*${label}/{:a;n;p;ba};" $0 | 
          grep -v ':$')
    eval "$cmd"
    exit
}

: ngrok
clear


# File where auth token will be stored
TOKEN_FILE="AUTH-TOKEN"

# Check if the AUTH-TOKEN file exists and is not empty
if [ -s "$TOKEN_FILE" ]; then
    # Read the token from the file
    CRP=$(cat "$TOKEN_FILE")
    echo "Ngrok Authtoken read from file."
else
    # If the file doesn't exist or is empty, ask for the token
    read -p "Paste Ngrok Authtoken: " CRP
    # Save the token to the AUTH-TOKEN file
    echo "$CRP" > "$TOKEN_FILE"
    echo "Ngrok Authtoken saved to file."
fi

# Add the auth token to ngrok config
./ngrok config add-authtoken $CRP

clear


# Start ngrok with the saved region
./ngrok http --region us 3001 &>/dev/null &
clear
sleep 1
if curl --silent --show-error http://127.0.0.1:4040/api/tunnels  > /dev/null 2>&1; then echo OK; else echo "Ngrok Error! Please try again!" && sleep 1 && goto ngrok; fi
sleep 1
clear
docker run --restart always -d -p 3000:3000 --privileged --name nomashine --cap-add=SYS_PTRACE --shm-size=7g -e USERP='5022' -e VNCP='5022' a35379/rdp:chrome

read -p "SET VNC PASSWORD: " CRP
docker run --restart always -d -p 3001:3000 --privileged --name nomashine1 --cap-add=SYS_PTRACE --shm-size=7g -e USERP='5022' -e VNCP="$CRP" a35379/rdp:9

clear
clear

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
docker exec -it nomashine /bin/sh -c "git clone https://github.com/3222h/vs-ter-01.git"
clear
curl ifconfig.me
echo
echo

sleep 1
CRP=$(cat ./STOP-URL)
CODESPACE_URL="https://$CRP-3000.app.github.dev"

echo "$CODESPACE_URL"

echo
public_url=$(curl --silent --show-error http://127.0.0.1:4040/api/tunnels | sed -nE 's/.*"public_url":"(https:\/\/[^"]*).*/\1/p')
echo "$public_url"
echo
echo
echo
