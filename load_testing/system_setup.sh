#!/bin/bash

transaction_csv=${transaction_csv:-./load_testing/transactions.csv}
numOfTxs=500
wallet_csv=${wallet_csv:-./load_testing/wallets.csv}
numOfWallets=50
threadCount=5

cd "$(dirname "$0")"
mkdir -p dump &&
rm -f ./dump/*  &&
./system_launch.sh -r &&
docker exec opencbdc-tx_client ./load_testing/gen_test_env.sh -w $wallet_csv -t $transaction_csv -n $numOfTxs -c $numOfWallets && 
docker cp  opencbdc-tx_client:/opt/tx-processor/load_testing/wallets.csv dump/ &&
docker cp  opencbdc-tx_client:/opt/tx-processor/load_testing/transactions.csv dump/ &&
echo "Exported test dataset to dump/" &&
echo "Starting Jmeter test with $threadCount threads on $numOfWallets wallets and $numOfTxs txs" &&
docker exec opencbdc-tx_client /opt/apache-jmeter-5.4.3/bin/jmeter -t ./load_testing/TransactionTest_remote.jmx -l ./load_testing/dump/results.jtl -j ./load_testing/dump/jmeter.log -n -DtxCount=$numOfTxs -Dthreadcount=$threadCount &&
docker cp opencbdc-tx_client:/opt/tx-processor/load_testing/dump/ . &&
echo "Exported results to dump/"