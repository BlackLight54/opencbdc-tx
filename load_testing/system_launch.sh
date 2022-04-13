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
echo "Starting service..."
dockerBuild(){
    if [ "$REBUILD" == true ]; then
    echo "Building Docker container..."
    docker build . -t opencbdc-tx   && # build the container
    echo "Build Complete."
    fi
}
dockerCompose(){
    
    echo "Running Docker-compose..."
    if [ "$RESET" == false ]; then
        docker-compose --file $COMPOSE_FILE up --detach || exit 1;
    else
        docker-compose --file $COMPOSE_FILE up --force-recreate --detach || exit 1;
    fi
}
   
startClient(){
SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`
SCRIPTPATH="$SCRIPTPATH/load_testing"

    echo "Removing old client..."
    docker rm -f opencbdc-tx_client && echo "Removed old client."
    echo "Starting client..."
    echo $SCRIPTPATH
    docker run -d --network 2pc-network --name opencbdc-tx_client -p 1099:1099 -p 4000:4000 --mount type=bind,source=$SCRIPTPATH,target=/opt/tx-processor/load_testing -ti opencbdc-tx /bin/bash &&
    echo "Client is up." &&    
    docker network connect bridge opencbdc-tx_client &&
    echo "Client is connected to bridge network."
}
dockerBuild &&
dockerCompose &&
startClient &&
echo "Docker ips:" &&
docker inspect --format "{{ .Name }} => {{ .NetworkSettings.IPAddress }}" $(docker ps -a -q)
