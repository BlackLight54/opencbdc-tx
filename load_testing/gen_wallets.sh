#!/bin/bash
cd "$(dirname "$0")"
cd ..

while getopts w:n:v: flag
do
    case "${flag}" in
        w) wallet_csv=${OPTARG};;
        n) numOfWallets=${OPTARG};;
        v) amount=${OPTARG};;
    esac
done

wallet_csv=${wallet_csv:-./load_testing/wallets.csv}
numOfWallets=${numOfWallets:-5}
amount=${amount:-10}
remote=${remote:-false}

echo "Generating wallets in $PWD, data set in $PWD/$wallet_csv"
echo "Resetting csv..."
rm -f $wallet_csv
touch $wallet_csv
#printf "id,mempool,wallet,address\n" >> $wallet_csv
( for ((i=0; i<numOfWallets; i++));   
do    
        #echo "Creating wallet $i..."
        printf "$i,mempool$i.dat,wallet$i.dat," >> $wallet_csv
        if [ ${remote} == "false" ];
        then (docker exec opencbdc-tx_client ./build/src/uhs/client/client-cli 2pc-compose.cfg mempool$i.dat wallet$i.dat newaddress | tee >( tail -1 >> $wallet_csv)) ;
        else ./build/src/uhs/client/client-cli ./2pc-compose.cfg mempool$i.dat wallet$i.dat newaddress |  tail -1 >> $wallet_csv ;
        fi
done

) && ./load_testing/mint.sh -w $wallet_csv -c $numOfWallets -v $amount && echo "Done."

