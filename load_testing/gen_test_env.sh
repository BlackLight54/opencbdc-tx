#!/bin/bash
while getopts w:n:t:c: flag
do
    case "${flag}" in
        w) wallet_csv=${OPTARG};;
        t) transaction_csv=${OPTARG};;
        n) numOfTxs=${OPTARG};;
        c) numOfWallets=${OPTARG};;
    esac
done


transaction_csv=${transaction_csv:-./load_testing/transactions.csv}
numOfTxs=${numOfTxs:-20}
wallet_csv=${wallet_csv:-./load_testing/wallets.csv}
numOfWallets=${numOfWallets:-5}

remote=${remote:-false}

[ $remote == true ] && echo "Running in remote mode." && cd "$(dirname "$0")"
./gen_wallets.sh -w $wallet_csv -n $numOfWallets &&
./gen_transfers.sh -w $wallet_csv -t $transaction_csv -n $numOfTxs 