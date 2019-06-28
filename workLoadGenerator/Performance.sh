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

Reset(){
	rm $path_tps
	rm $path_txRate
	rm $path_latency
	touch $path_tps
	touch $path_txRate
	touch $path_latency
}

WorkLoad(){
	node $path_workload $1 $2 
}

SCP_instance(){

	gcloud compute --project "caideyi" ssh --zone "asia-east1-b" "$1" -- './TendermintOnEvm_benchmark/scp.sh'
	echo "Transfer done!!"

}

main(){

	echo "-------Start Testing--------"
	for ((j=0 ; j<$3 ; j++)){
		ResetLogFile
		WorkLoad $1 $2
	        echo "Transfer data....."	
		sleep 5
		#SCP_instance $4
		echo "CalPerformance....."
		python $path_cal 

	}
}

Reset
main $1 $2 $3 $4    ##[1] sleep time : ms  [2] tx_num  [3]: iter [4]: instance name
python variance.py