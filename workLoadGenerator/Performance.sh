path=$HOME/TendermintOnEvm_benchmark/data
path_blockTxNum=$path/blockTxNum.txt
path_blockCommitTime=$path/blockCommitTime.txt
path_txRequestTime=$path/txRequestTime.txt
path_rawData=$path/rawData
path_log=$path/log
path_repeatHash=$path/repeatHash
path_nonce=$path/nonceTooHigh
path_preCommitTime=$path/pre_BlockCommitTime.txt
path_tf=$path/tf
####################################################
path2=$HOME/TendermintOnEvm_benchmark/report
path_report=$path2/report
path_tps=$path2/tps.txt
path_txRate=$path2/txRate.txt
path_latency=$path2/latency.txt
path_fail=$path2/fail.txt
####################################################
path_avg_tps=$path2/tps
path_avg_latency=$path2/latency
path_avg_txRate=$path2/txRate
path_avg_fail=$path2/fail
path_workload=$HOME/evm-lite-js/test/workload.js
path_cal=$HOME/evm-lite-js/test/cal.py


ResetLogFile(){
	./reset.sh
}

Cal_tps(){
	avg_tps=0
	l=$(cat $path_tps | wc -l)
	for line in `cat $path_tps`
	do
		avg_tps=$(echo "scale=4;$avg_tps+$line" | bc)
	done

	echo "scale=4;$avg_tps/$l" | bc
}
Cal_latency(){
	avg_latency=0
	l=$(cat $path_latency | wc -l)
	for line in `cat $path_latency`
	do
		avg_latency=$(echo "scale=4;$avg_latency+$line" | bc)
	done
	echo "scale=4;$avg_latency/$l" | bc
}
Cal_txRate(){
	avg_txRate=0
	l=$(cat $path_txRate | wc -l)
	for line in `cat $path_txRate`
	do
		avg_txRate=$(echo "scale=4;$avg_txRate+$line" | bc)
	done
	echo "scale=4;$avg_txRate/$l" | bc
}
Cal_failTx(){
	avg_fail=0
	l=$(cat $path_fail | wc -l)
	for line in `cat $path_fail`
	do
		avg_fail=$(echo "scale=4;$avg_fail+$line" | bc)
	done
	echo "scale=4;$avg_fail/$l" | bc
}
Reset(){
	rm $path_tps
	rm $path_txRate
	rm $path_latency
	rm $path_fail
	touch $path_tps
	touch $path_txRate
	touch $path_latency
	touch $path_fail
}

WorkLoad(){
	node $path_workload $1 $2 
}

SCP_instance(){

	gcloud compute --project "caideyi" ssh --zone "asia-east1-b" "$1" -- './TendermintOnEvm_benchmark/scp.sh'
	echo "Transfer done!!"

}

main(){

	for ((j=0 ; j<$3 ; j++)){
		ResetLogFile
		start_time=$( date +%s.%N )
		#for ((i=1 ; i<2 ; i++)){
		#	WorkLoad $1 $2 $3 &
		#}
		WorkLoad $1 $2 
		elapsed_time=$( date +%s.%N --date="$start_time seconds ago" )
		echo "TimeLeft= $elapsed_time"
		sleep 2
		SCP_instance $4
		echo "CalPerformance....."
		python $path_cal 

	}
}

Reset
main $1 $2 $3 $4    ##[1] sleep time : ms [2] iter   [3]: iter
tps=$(Cal_tps)
latency=$(Cal_latency)
tx_rate=$(Cal_txRate)
echo $tps >> $path_avg_tps
echo $latency >> $path_avg_latency
echo $tx_rate >> $path_avg_txRate
#Reset
