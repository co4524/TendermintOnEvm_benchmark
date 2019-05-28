commit_time=0

Get_request_num(){
	request_num=$(wc -l txRequestTime.txt)
	request_num=$(echo $request_num | grep -o '[0-9]*')
	echo $request_num
}

total_tx_num=$(Get_request_num)

Get_tx_rate(){
	end=$(sed -n '$p' txRequestTime.txt)
	start=$(sed -n 1p txRequestTime.txt)
	echo "total_send= $total_tx_num" >> Report.txt
	echo "Send_start_time= $start" >> Report.txt
	echo "Send_end_time= $end" >> Report.txt
	time=$(echo "scale=4;$end-$start" | bc)
	echo "scale=4;$total_tx_num/$time" | bc
}

Get_success_tx(){
	success_tx=0
	for line in `cat blockTxNum.txt`
	do
		success_tx=$(($success_tx+$line))
	done
	echo $success_tx
}

Get_success_tx_tps(){
	success_tx=0
	final_point=$(sed -n '$p' blockTxNum.txt)
	for line in `cat blockTxNum.txt`
	do
		success_tx=$(($success_tx+$line))
	done
	blockheight=$(cat blockTxNum.txt | wc -l)
	if [ $blockheight -gt 1 ]
	then
		success_tx=$(($success_tx-$final_point))
	fi

	echo $success_tx
}

DeletFailTx(){
	success_tx=$(Get_success_tx)
	request_num=$(Get_request_num)
	fail_tx=$(($request_num-$success_tx))
	deletLine=$(($request_num/2))
	echo $fail_tx
	for((i=0 ; i<$fail_tx ; i++)){
		sed -i "$deletLine"d txRequestTime.txt
		request_num=$(Get_request_num)
		deletLine=$(($request_num/2))
	}
}

CalculateLatency(){
	n=1
	m=1
	sum=0
	for line in `cat blockTxNum.txt`
	do
		for((i=0 ; i<$line ; i++)){
			commit_time=$(sed -n "$n"p pro_BlockCommitTime.txt)
			txRequest_time=$(sed -n "$m"p txRequestTime.txt) 
			latency=$(echo "scale=4;$commit_time-$txRequest_time" | bc)
			sum=$(echo "scale=4;$sum+$latency" | bc)
			m=$(($m+1))
	}
	n=$(($n+1))
	done
	avg_latency=$(echo "scale=4;$sum/$(Get_request_num)" | bc)
	echo "AvgLatencyTime= $avg_latency" >> Report.txt
	echo $avg_latency >> latency.txt

}

CalculateTps(){
	blockheight=$(cat blockCommitTime.txt | wc -l)
	if [ $blockheight -gt 1 ]
	then
		blockheight=$(($blockheight-1))
	fi
	tx_start_time=$(sed -n 1p txRequestTime.txt)
	commit_time=$(sed -n "$blockheight"p pro_BlockCommitTime.txt)
	success_tx=$(Get_success_tx_tps)
	echo $success_tx
	echo "start_time= $tx_start_time" >> Report.txt
	echo "end_time= $commit_time" >> Report.txt
	total_time=$(echo "scale=4;$commit_time-$tx_start_time" | bc)
	echo "dur_time= $total_time" >> Report.txt
	tps=$(echo "scale=4;$success_tx/$total_time" | bc)
	echo "TPS =$tps" >> Report.txt
	echo $tps >> tps.txt
}

PreprocessTxt(){
	comma='.'
	for line in `cat blockCommitTime.txt`
	do
		integer=${line:0:10}
		decimal=${line:10:12}
		echo $integer$comma$decimal >> pro_BlockCommitTime.txt
	done

}
echo "" >> Report.txt
echo "----------------TestResult-----------------" >> Report.txt
tx_rate=$(Get_tx_rate)
echo "Tx_rate= $tx_rate" >> Report.txt
echo $tx_rate >> tx_rate.txt
failTx=$(DeletFailTx)
PreprocessTxt
CalculateLatency
CalculateTps
echo "failTx: $failTx" >> Report.txt
echo $failTx >> failtx.txt
echo "-------------------------------------------" >> Report.txt
