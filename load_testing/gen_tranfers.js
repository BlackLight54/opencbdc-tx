//Ez a script egy bemeneti id,mempool,wallet,address jellegű CSV-ből generál random from_id,from_mempool,from_wallet,to_mempool,to_wallet,to_address jellegű csv-t
//Első argmunetum: Input CSV
//Második argumentum: Kimeneti fájl
//Harmadik argumentum transferek (kimeneti sorok) száma
const fs = require('fs');

function getTwoNonIdenticalRandomInts(max){
    let rand1 = 0;
    let rand2 = 0;
    while(rand1 == rand2){
        rand1 = Math.round(Math.random() * (max-1));        
        rand2 = Math.round(Math.random() * (max-1));        
    }
    return [rand1, rand2];
}

console.log(`Generating ${process.argv[4]} random transactions from ${process.argv[2]} to ${process.argv[3]} CSV...`);
fs.readFile(process.argv[2], function(err, data) {  
    const list = data.toString().replace(/\r\n/g,'\n').split('\n');
    if(process.argv.length > 4){
        var stream = fs.createWriteStream(process.argv[3]);
        stream.write(`id,from_id,from_mempool,from_wallet,to_id,to_mempool,to_wallet,to_address\n`);
        for(let i = 0; i < process.argv[4]; i++){
            var [idx1, idx2] = getTwoNonIdenticalRandomInts(list.length -1);
            fromId = list[idx1].split(',')[0]
            fromMempool = list[idx1].split(',')[1]
            fromWallet = list[idx1].split(',')[2]

            toId = list[idx2].split(',')[0]
            toMempool = list[idx2].split(',')[1]
            toWallet = list[idx2].split(',')[2]
            toAddress = list[idx2].split(',')[3]
            
            stream.write(`${i},${fromId},${fromMempool},${fromWallet},${toId},${toMempool},${toWallet},${toAddress}\n`);
        }
        stream.end();
    }    
});