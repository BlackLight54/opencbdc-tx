#!/bin/bash
wallet_csv=${3:-"wallets.csv"}
transaction_csv=${4:-"transactions.csv"}
numOfWallets=${1:-5}
numOfTxs=${2:-20}
echo "Resetting csv..."
rm -f $wallet_csv
#printf "id,mempool,wallet,address\n" >> $wallet_csv
for ((i=0; i<numOfWallets; i++));   
do    
    echo "Creating wallet $i..."
    printf "$i,mempool$i.dat,wallet$i.dat," >> $wallet_csv
    docker exec opencbdc-tx_client ./build/src/uhs/client/client-cli 2pc-compose.cfg mempool$i.dat wallet$i.dat newaddress | tee >( tail -1 >> $wallet_csv)  
done
echo "Generating transactions..."
node gen_tranfers.js $wallet_csv $transaction_csv $numOfTxs
echo "Done."