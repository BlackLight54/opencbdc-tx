@echo off  
jmeter -t TransactionTest.jmx -l \dump\results.jtl -j \dump\jmeter.log