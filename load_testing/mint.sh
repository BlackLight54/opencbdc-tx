#!/bin/bash
cd "$(dirname "$0")"
cd ..
remote=${remote:-false}

while getopts c:v:w:r flag
do
    case "${flag}" in
        w) wallet_csv=${OPTARG};;
        c) numOfWallets=${OPTARG};;
        v) amount=${OPTARG};;
        r) RANDOM=true;;
    esac
done

utxo_count=${utxo_count:-10}
amount=${amount:-10}
wallet_csv=${wallet_csv:-"./load_testing/wallets.csv"}
RANDOM=${RANDOM:-false}

echo "Minting to each wallet..."
cat ${wallet_csv} | while read line; do
    id=$(echo $line | cut -d',' -f1)
    mempool=$(echo $line | cut -d',' -f2)
    wallet=$(echo $line | cut -d',' -f3)
    if [ "$RAND" == true ]; then
        amountMax=${amountMax:-$amount}
        utxo_count_max=${utxo_count_max:-$utxo_count}
        amount=$((RANDOM%$amountMax + 1 ))
    utxo_count=$((RANDOM%$utxo_count_max + 1))
    fi
    
    # echo "Minting $utxo_count UTXOs each worth ${amount}c to wallet$id... " 

        if [ "$remote" == true ];
        then  ./build/src/uhs/client/client-cli ./2pc-compose.cfg $mempool $wallet mint  $utxo_count $amount  >> /dev/null ;
        else docker exec opencbdc-tx_client ./build/src/uhs/client/client-cli 2pc-compose.cfg $mempool $wallet mint  $utxo_count $amount  >> /dev/null;
        fi

done




