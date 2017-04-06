#!/bin/bash
# Launches a docker container with working X11 forwarding.

if [ "$(uname)" == "Darwin" ]; then
    open -a XQuartz
fi

if [ -z "$DISPLAY" ]; then
    echo "DISPLAY not set, not setting up X11 forwarding"
fi

# parse DISPLAY into three parts:
#   <display_host>:<display_display>.<display_screen>
display_host=${DISPLAY%%:*}
if [[ $DISPLAY == *:* ]]; then
    display_displayscreen=${DISPLAY#*:}
    display_display=${display_displayscreen%%.*}
    if [[ $display_displayscreen == *.* ]]; then
        display_screen=${display_displayscreen#*.}
    fi
elif [[ $DISPLAY == *.* ]]; then
    echo "Invalid DISPLAY variable"
    exit 1
fi

# setup socat arguments

if [[ -n "$display_host" ]]; then
    socat1="TCP-LISTEN:6001,fork"
    if [[ "$display_host" == */* ]]; then
        socat2="UNIX-CLIENT:\"$DISPLAY\""
    else
        socat2="TCP:$display_host:60$(printf "%02d" $display_display)"
    fi
    if [ "$(uname)" == "Darwin" ]; then
        host_ip=$(ipconfig getifaddr en0)
    else
        host_ip=$(ip route get 1 | awk '{print $NF;exit}')
    fi

    xauth_magic=$(xauth list ":$display_display" | awk '{print $3}')
fi

# kill child processes on signals
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# run socat as background job
echo socat $socat1 $socat2
socat $socat1 $socat2 &
socat_pid=$!
sleep 0.5
if ! kill -0 "$socat_pid" ; then
    echo "socat failed to start"
    exit 1
fi

# setup display variable to pass in
container_display="$host_ip:1"

# create Xauth file
AUTH_DIR="/tmp/.docker_run"
mkdir -p "$AUTH_DIR"
xauth_file="$AUTH_DIR/xauth.$(uuidgen)"
touch "$xauth_file"
xauth -f "$xauth_file" add $container_display . $xauth_magic

echo $container_display
echo $xauth_magic

# run docker
sudo docker run -it \
    -p 8888:8888 \
    -p 6006:6006 \
    -v ~/dockershare:/root/share \
    -v $xauth_file:/tmp/Xauthority \
    -e DISPLAY=$container_display \
    -e XAUTHORITY=/tmp/Xauthority \
    openai-gym \
    bash
