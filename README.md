Description
-----------
A docker container that provides everything you need to write openai gym agents. It's based on https://github.com/floydhub/dl-docker, which provides the major deep learning frameworks out of the box.

This container is CPU only. It will need to be modified to work with nvidia-docker.

This document assumes your host is OSX, but the process is very similar for
Linux.

You can skip the socat/XQuartz/DISPLAY related parts if you'll be running headless.

Setup
-----

Install docker via instructions here: https://docs.docker.com/docker-for-mac/install/#download-docker-for-mac

Build the image:

    docker build -t openai-gym:cpu -f Dockerfile.cpu .

Install socat (for X11 port forwarding):

    sudo port install socat

Make a host directory to share with the docker image:

    mkdir ~/dockershare

Running the image
-----------------

Run XQuartz on the host and forward the X port via TCP:

    open -a XQuartz
    socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\"

Run:

    docker run -it -p 8888:8888 -p 6006:6006 -v ~/dockershare:/root/share -e DISPLAY=192.168.86.170:0 openai-gym bash

Running a TRPO agent
--------------------

Clone this repo into your ~/dockershare directory: https://github.com/joschu/modular_rl

Inside your container run:

    cd ~/share/modular_rl
    xvfb-run -s "-screen 0 1400x900x24" /bin/bash
    python run_pg.py --gamma=0.995 --lam=0.97 --agent=modular_rl.agentzoo.TrpoAgent --max_kl=0.01 --cg_damping=0.1 --activation=tanh --n_iter=250 --seed=0 --timesteps_per_batch=40000 --env=AirRaid-ram-v0 --outfile=/root/share/AirRaid-ram-v0.h5

