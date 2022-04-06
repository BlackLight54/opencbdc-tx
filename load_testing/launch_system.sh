#!/bin/bash
while [[ $# -gt 0 ]]; do
  case $1 in
    -r|--reset)
        RESET=true;
        shift # past argument
        ;;
    -b|--build)
        REBUILD=true;
        shift # past argument
        ;;
    -f|--file)
        COMPOSE_FILE="$2";
        shift # past argument
        shift # past value
        ;;
    -h|--help)
        echo "Usage: ./launch_system.sh [OPTIONS]"
        echo "Options:"
        echo "  -r, --reset: Reset the container"
        echo "  -b, --build: Rebuild the container"
        echo "  -f, --file: Specify the docker-compose file"
        echo "  -h, --help:  Show this message"
        exit 0
        ;;
    
  esac
done

RESET=${RESET:-false};
REBUILD=${REBUILD:-false};
COMPOSE_FILE=${COMPOSE_FILE:-"docker-compose-2pc.yml"};
cd ..
if [ "$REBUILD" == true ]; then
echo "Building Docker container..."
docker build . -t opencbdc-tx  # build the container
fi

echo "Starting service..."
echo "Running Docker-compose..."
if [ "$RESET" == false ]; then
    docker-compose --file $COMPOSE_FILE up --detach;
else
    docker-compose --file $COMPOSE_FILE up --force-recreate --detach;
fi
waitForSentinel(){
until [ "`docker inspect --format='{{.State.Running}}' opencbdc-tx_sentinel0_1`"=="true" ]; do
    sleep 0.1;
done;
echo "Sentinel is up."
}
waitForCoordinator(){
until [ "`docker inspect --format='{{.State.Running}}' opencbdc-tx_coordinator0_1`"=="true" ]; do
    sleep 0.1;
done;
echo "Coordinator is up."
}
waitForShard(){
until [ "`docker inspect --format='{{.State.Running}}' opencbdc-tx_shard0_1`"=="true" ]; do
    sleep 0.1;
done;
echo "Shard is up."
}

waitForSentinel &
waitForCoordinator &
waitForShard &
wait    
startClient(){
    echo "Removing old client..."
    docker rm -f opencbdc-tx_client
    echo "Starting client..."
    docker run -d --network 2pc-network --name opencbdc-tx_client -ti opencbdc-tx /bin/bash

    until [ "`docker inspect --format='{{.State.Running}}' opencbdc-tx_client`"=="true" ]; do
        sleep 0.1;
    done;
    echo "Client is up."
}
if [ "`docker inspect --format='{{.State.Running}}' opencbdc-tx_sentinel0_1`"=="true" ] && [ "`docker inspect --format='{{.State.Running}}' opencbdc-tx_coordinator0_1`"=="true" ] && [ "`docker inspect --format='{{.State.Running}}' opencbdc-tx_shard0_1`"=="true" ]; then
    startClient
fi
