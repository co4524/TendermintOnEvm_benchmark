tps=0
latency=0
tx_rate=0
failTx=0
Cal_tps(){
	avg_tps=0
	l=$(cat tps.txt | wc -l)
	for line in `cat tps.txt`
	do
		avg_tps=$(echo "scale=4;$avg_tps+$line" | bc)
	done

	echo "scale=4;$avg_tps/$l" | bc
}
Cal_latency(){
	avg_latency=0
	l=$(cat latency.txt | wc -l)
	for line in `cat latency.txt`
	do
		avg_latency=$(echo "scale=4;$avg_latency+$line" | bc)
	done
	echo "scale=4;$avg_latency/$l" | bc
}
Cal_txRate(){
	avg_txRate=0
	l=$(cat tx_rate.txt | wc -l)
	for line in `cat tx_rate.txt`
	do
		avg_txRate=$(echo "scale=4;$avg_txRate+$line" | bc)
	done
	echo "scale=4;$avg_txRate/$l" | bc
}
Cal_failTx(){
	avg_fail=0
	l=$(cat failtx.txt | wc -l)
	for line in `cat failtx.txt`
	do
		avg_fail=$(echo "scale=4;$avg_fail+$line" | bc)
	done
	echo "scale=4;$avg_fail/$l" | bc
}
Reset(){
	rm failtx.txt
	rm tx_rate.txt
	rm latency.txt
	rm tps.txt
	touch failtx.txt
	touch tx_rate.txt
	touch latency.txt
	touch tps.txt
}
##Begin Test##
for ((j=0 ; j<5 ; j++)){
	./resetTXT.sh
	#for ((i=1 ; i<$3 ; i++)){
	#	./workload.sh $1 $2 &
	#}
	./workload.sh $1 $2
	echo "done"
	sleep 2
	./tpsCal.sh
}
##Eval data
tps=$(Cal_tps)
latency=$(Cal_latency)
tx_rate=$(Cal_txRate)
failTx=$(Cal_failTx)
#Reset
echo $tps >> 1
echo $latency >> 2
echo $tx_rate >> 3
echo $failTx >> 4
Reset
