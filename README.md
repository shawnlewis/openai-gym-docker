Description
-----------
A docker container that provides everything you need to write openai gym agents. It's based on https://github.com/floydhub/dl-docker, which provides the major deep learning frameworks out of the box.

This container is CPU only. It will need to be modified to work with nvidia-docker.

Setup
-----

### General steps on an OSX host

Install socat (for X11 port forwarding):

    sudo port install socat

Install docker via instructions here: https://docs.docker.com/docker-for-mac/install/#download-docker-for-mac

### General steps on a Linux host

Install docker via instructions here: https://docs.docker.com/engine/installation/linux/ubuntu/#install-docker

### General steps, all hosts

Make a host directory to share with the docker image:

    mkdir ~/dockershare

### Docker image (cpu)

Build the image:

    docker build -t openai-gym:cpu -f Dockerfile.cpu .

### Docker image (gpu, Linux only)

Build dl-docker gpu

    git clone https://github.com/saiprashanths/dl-docker.git
    cd dl-docker
    docker build -t floydhub/dl-docker:gpu -f Dockerfile.gpu .

Build the image:

    docker build -t openai-gym:cpu -f Dockerfile.gpu .


Running the image
-----------------

run.sh sets up X forwarding automatically, and launches the container.

    ./run.sh

Running a TRPO agent
--------------------

Clone this repo into your ~/dockershare directory: https://github.com/shawnlewis/modular_rl

Inside your container run:

    cd ~/share/modular_rl
    ./run.sh
