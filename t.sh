#!/bin/bash
stty intr ""
stty quit ""
stty susp undef

docker stop nomashine1
sleep 2
docker rm nomashine1
sleep 2
docker run --network nomashine1 --restart always -d -p 3001:3000 --privileged --name nomashine1 --cap-add=SYS_PTRACE --shm-size=7g -e USERP='ubuntu' -e VNCP='ubuntu' a35379/rdp:t
