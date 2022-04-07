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
dockerBuild(){
    if [ "$REBUILD" == true ]; then
    echo "Building Docker container..."
    docker build . -t opencbdc-tx  # build the container
    fi
}
dockerCompose(){
    echo "Starting service..."
    echo "Running Docker-compose..."
    if [ "$RESET" == false ]; then
        docker-compose --file $COMPOSE_FILE up --detach || exit 1;
    else
        docker-compose --file $COMPOSE_FILE up --force-recreate --detach || exit 1;
    fi
}
   
startClient(){
    echo "Removing old client..."
    docker rm -f opencbdc-tx_client && echo "Removed old client."
    echo "Starting client..."
    docker run -d --network 2pc-network --name opencbdc-tx_client -p 1099:1099 -p 4000:4000 -ti opencbdc-tx /bin/bash &&
    echo "Client is up."
    
    docker network connect bridge opencbdc-tx_client &&
    echo "Client is connected to bridge network."
}
dockerBuild &&
dockerCompose &&
startClient &&
echo "Docker ips:" &&
docker inspect --format "{{ .Name }} => {{ .NetworkSettings.IPAddress }}" $(docker ps -a -q)
