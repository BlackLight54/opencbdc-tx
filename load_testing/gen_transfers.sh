#!/bin/bash
cd "$(dirname "$0")"
cd ..

while getopts w:n:t: flag
do
    case "${flag}" in
        w) wallet_csv=${OPTARG};;
        t) transaction_csv=${OPTARG};;
        n) numOfTxs=${OPTARG};;
    esac
done

wallet_csv=${wallet_csv:-./load_testing/wallets.csv}
transaction_csv=${transaction_csv:-./load_testing/transactions.csv}
numOfTxs=${numOfTxs:-20}

echo "Generating transactions data set in $PWD/$transaction_csv"
node ./load_testing/gen_tranfers.js $wallet_csv $transaction_csv $numOfTxs && 
echo "Done."
