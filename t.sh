#!/bin/bash
stty intr ""
stty quit ""
stty susp undef

docker stop nomashine1
sleep 1
docker rm nomashine1
sleep 1

PSW_FILE="PSW"
if [ -s "$PSW_FILE" ]; then
    PSW=$(cat "$PSW_FILE")
    echo "PASSWORD READED FROM FILE: $PSW."
else
    read -p "CHOOSE PASSWORD OF FOUR NUMBERS ( 1,2,3,4,5,6,7,8,9 ): " PSW
    echo "$PSW" > "$PSW_FILE"
    echo "PASSWORD SAVED TO FILE."
fi
docker run --network nomashine1 --restart always -d -p 3001:3000 --privileged --name nomashine1 --cap-add=SYS_PTRACE --shm-size=7g -e USERP="$PSW" -e VNCP="$PSW" a35379/rdp:t
