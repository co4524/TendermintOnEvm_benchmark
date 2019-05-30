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

Send_tx(){
	start_time=$( date +%s.%N )
	curl -X POST http://$4:8080/tx -d '{"from":"'0x$1'","to":"'0x$2'","value":'$3'}' -s
	echo $start_time >> $path_txRequestTime
}

WorkLoad(){
	for ((i=0;i<$2;i++)){
		Send_tx d3fe6e278f533c62dc0ffe060af4bb09b79ed0df 2100f32235a599dd1ad6cc24bb54c856a9f12798 1 $3 >> $path_rawData & 
		sleep $1
		Send_tx b2f094f1ba8bbb363c128b37fbe83235b3bfc0a9 2100f32235a599dd1ad6cc24bb54c856a9f12798 1 $3 >> $path_rawData &
		sleep $1
		Send_tx d22312c75d4132959777c8d79bf402f31ab688dc 2100f32235a599dd1ad6cc24bb54c856a9f12798 1 $3 >> $path_rawData &
		sleep $1
		Send_tx 1f3e38f742d9a73483c3f80fdd5d116d61438db5 2100f32235a599dd1ad6cc24bb54c856a9f12798 1 $3 >> $path_rawData &
		sleep $1
	}
}

main(){

	for ((j=0 ; j<$3 ; j++)){
		echo "StartTesting"
		ResetLogFile
		start_time=$( date +%s.%N )
		for ((i=1 ; i<2 ; i++)){
			WorkLoad $1 $2 localhost &
		}
		WorkLoad $1 $2 localhost
		elapsed_time=$( date +%s.%N --date="$start_time seconds ago" )
		echo "TimeLeft= $elapsed_time"
	sleep 2
	echo "CalPerformance....."
	./calResult.sh

	}
}

Reset
main $1 $2 $3
##Eval data
tps=$(Cal_tps)
latency=$(Cal_latency)
tx_rate=$(Cal_txRate)
failTx=$(Cal_failTx)
echo $tps >> $path_avg_tps
echo $latency >> $path_avg_latency
echo $tx_rate >> $path_avg_txRate
echo $failTx >> $path_avg_fail
#Reset
