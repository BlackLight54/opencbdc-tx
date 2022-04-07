@echo off  
jmeter -t TransactionTest_remote.jmx -l \dump\results.jtl -j \dump\jmeter.log 