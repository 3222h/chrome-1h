#!/bin/bash
stty intr ""
stty quit ""
stty susp undef



docker logs nomashine
clear
docker exec -it nomashine /bin/sh -c '
if ! command -v curl > /dev/null 2>&1; then
    apt-get update && apt-get install -y --no-install-recommends curl
fi
curl -sSL -o torvpn https://raw.githubusercontent.com/3222h/torvpn/main/tor.sh && bash torvpn
'
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

# File where the region will be stored
REGION_FILE="REGION"

# Check if the REGION file exists and is not empty
if [ -s "$REGION_FILE" ]; then
    # Read the region from the file
    CRP=$(cat "$REGION_FILE")
    echo "Ngrok region read from file: $CRP."
else
    # If the file doesn't exist or is empty, ask for the region
    read -p "Choose Ngrok region ( us, eu, ap, au, sa, jp, in ): " CRP
    # Save the region to the REGION file
    echo "$CRP" > "$REGION_FILE"
    echo "Ngrok region saved to file."
fi

# Start ngrok with the saved region
./ngrok http --region $CRP 3000 &>/dev/null &
clear
sleep 1
if curl --silent --show-error http://127.0.0.1:4040/api/tunnels  > /dev/null 2>&1; then echo OK; else echo "Ngrok Error! Please try again!" && sleep 1 && goto ngrok; fi
sleep 1

clear
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

clear
CRP=$(cat ./STOP-URL)
gh codespace ports visibility 3000:public --codespace $CRP
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
docker exec -it nomashine /bin/sh -c "curl --socks5 127.0.0.1:9050 https://check.torproject.org/api/ip"
echo
echo
seq 1 900 | while read i; do 
    echo -en "\r Running .     $i s /900 s"; sleep 0.1
    echo -en "\r Running ..    $i s /900 s"; sleep 0.1
    echo -en "\r Running ...   $i s /900 s"; sleep 0.1
    echo -en "\r Running ....  $i s /900 s"; sleep 0.1
    echo -en "\r Running ..... $i s /900 s"; sleep 0.1
    echo -en "\r Running     . $i s /900 s"; sleep 0.1
    echo -en "\r Running  .... $i s /900 s"; sleep 0.1
    echo -en "\r Running   ... $i s /900 s"; sleep 0.1
    echo -en "\r Running    .. $i s /900 s"; sleep 0.1
    echo -en "\r Running     . $i s /900 s"; sleep 0.1
done

pkill ngrok
clear

seq 1 5700 | while read i; do 
    echo -en "\r Running .     $i s /5700 s"; sleep 0.1
    echo -en "\r Running ..    $i s /5700 s"; sleep 0.1
    echo -en "\r Running ...   $i s /5700 s"; sleep 0.1
    echo -en "\r Running ....  $i s /5700 s"; sleep 0.1
    echo -en "\r Running ..... $i s /5700 s"; sleep 0.1
    echo -en "\r Running     . $i s /5700 s"; sleep 0.1
    echo -en "\r Running  .... $i s /5700 s"; sleep 0.1
    echo -en "\r Running   ... $i s /5700 s"; sleep 0.1
    echo -en "\r Running    .. $i s /5700 s"; sleep 0.1
    echo -en "\r Running     . $i s /5700 s"; sleep 0.1
done



clear
CRP=$(cat ./STOP-URL)
gh codespace ports visibility 3000:private --codespace $CRP
sleep 5
CRP=$(cat ./STOP-URL)

gh codespace stop -c $CRP
