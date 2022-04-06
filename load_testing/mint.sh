#!/bin/bash
while [[ $# -gt 0 ]]; do
  case $1 in
    -r|--random)
        RAND=true;
        shift # past argument
        ;;
    -h|--help)
        echo "Usage: ./mint.sh [OPTIONS]"
        echo "Options:"
        echo "  -r, --random: Random UTXO count and amount, max is argument"
        echo "  -h, --help:  Show this message"
        exit 0
        ;;
    
  esac
done
utxo_count=${1:-10}
amount=${2:-10}
echo "Minting to each wallet..."
cat wallets.csv | while read line; do
    id=$(echo $line | cut -d',' -f1)
    mempool=$(echo $line | cut -d',' -f2)
    wallet=$(echo $line | cut -d',' -f3)
    if [ "$RAND" == true ]; then
        amountMax=${amountMax:-$amount}
        utxo_count_max=${utxo_count_max:-$utxo_count}
        amount=$((RANDOM%$amountMax + 1 ))
    utxo_count=$((RANDOM%$utxo_count_max + 1))
    fi
    
    echo "Minting $utxo_count UTXOs each worth ${amount}c to wallet$id... "

    docker exec opencbdc-tx_client ./build/src/uhs/client/client-cli 2pc-compose.cfg $mempool $wallet mint  $utxo_count $amount 
done