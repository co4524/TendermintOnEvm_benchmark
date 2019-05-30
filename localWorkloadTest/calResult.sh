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

Get_tx_rate(){
	end=$(sed -n '$p' $path_txRequestTime)
	start=$(sed -n 1p $path_txRequestTime)
	echo "Send_start_time= $start" >> $path_report
	echo "Send_end_time= $end" >> $path_report
	time=$(echo "scale=4;$end-$start" | bc)
	tx_rate=$(echo "scale=4;$total_send/$time" | bc)
	echo "tx_rate= $tx_rate" >> $path_report
	echo "tx_rate= $tx_rate"
	echo $tx_rate >> $path_txRate
}


#去掉最後一個block裡面的tx
Get_success_tx_tps(){
	mod_success_tx=0
	final_point=$(sed -n '$p' $path_blockTxNum)
	for line in `cat $path_blockTxNum`
	do
		mod_success_tx=$(($mod_success_tx+$line))
	done
	blockheight=$(cat $path_blockTxNum | wc -l)
	if [ $blockheight -gt 1 ]
	then
		mod_success_tx=$(($mod_success_tx-$final_point))
	fi

	echo $mod_success_tx
}

CalculateTps(){
	blockheight=$(cat $path_blockCommitTime | wc -l)
	if [ $blockheight -gt 1 ]
	then
		blockheight=$(($blockheight-1))
	fi
	tx_start_time=$(sed -n 1p $path_txRequestTime)
	commit_time=$(sed -n "$blockheight"p $path_preCommitTime)
	tx_num=$(Get_success_tx_tps)
	echo "mod_tx_num= $tx_num" >> $path_report
	echo "start_time= $tx_start_time" >> $path_report
	echo "end_time= $commit_time" >> $path_report
	total_time=$(echo "scale=4;$commit_time-$tx_start_time" | bc)
	echo "dur_time= $total_time" >> $path_report
	tps=$(echo "scale=4;$tx_num/$total_time" | bc)
	echo "TPS =$tps" >> $path_report
	echo $tps >> $path_tps
}

PreprocessTxt(){
	comma='.'
	for line in `cat $path_blockCommitTime`
	do
		integer=${line:0:10}
		decimal=${line:10:12}
		echo $integer$comma$decimal >> $path_preCommitTime
	done

}

CalculateLatency(){
	n=1
	m=1
	sum=0
	for line in `cat $path_blockTxNum`
	do
		for((i=0 ; i<$line ; i++)){
			tmp=$(sed -n "$m"p $path_tf)
			if [ "$tmp" = T ]
			then
				commit_time=$(sed -n "$n"p $path_preCommitTime)
				txRequest_time=$(sed -n "$m"p $path_txRequestTime) 
				latency=$(echo "scale=4;$commit_time-$txRequest_time" | bc)
				sum=$(echo "scale=4;$sum+$latency" | bc)
			else
				let i=i-1
			fi
			m=$(($m+1))
	}
	n=$(($n+1))
	done
	avg_latency=$(echo "scale=4;$sum/$(Get_success_tx)" | bc)
	echo "AvgLatencyTime= $avg_latency" >> $path_report
	echo $avg_latency >> $path_latency

}

Get_request_num(){
	request_num=$(cat $path_txRequestTime | wc -l)
	echo $request_num
}

Get_success_tx(){
	success_tx=0
	for line in `cat $path_blockTxNum`                 #$1=path_blockTxNum
	do
		success_tx=$(($success_tx+$line))
	done
	echo $success_tx
}

Get_repeat_onetime_tx_hash(){
	cat $path_rawData | grep -o '[0n][0-9,a-z]*' >> $path_log
	sort $path_log |uniq -d >> $path_repeatHash
	var=$(cat $path_repeatHash | wc -l)
	echo $var
}
Get_nonce_too_high_tx(){
	cat $path_rawData | grep -o 'nonce too high' >> $path_nonce
	var=$(cat $path_nonce | wc -l)
	echo $var
}
Statist_Failtx(){

	num=1
	time=0
	success=true
	txPerBlock=$(sed -n 1p $path_blockTxNum)
	index=1
	for line in `cat $path_log`
	do
		success=true
		for line2 in `cat $path_repeatHash`
		do
			if [ "$line" = "$line2" ]
			then
				sed -i "/$line2/d" $path_repeatHash
				success=false
			fi
		done
		if [ "$line" = nonce ]
		then
			success=false
			#echo "nonce Too high"
		fi
		if [ "$success" = true ] 
		then 
			#echo "$num : success"
			echo T >> $path_tf
		else
			#echo "$num : fail"
			echo F >> $path_tf
			let txPerBlock=txPerBlock+1
		fi
		if [ "$num" -eq "$txPerBlock" ]
		then
			#echo "--------------------"
			index=$(($index+1))
			add_var=$(sed -n "$index"p $path_blockTxNum)
			let txPerBlock=txPerBlock+add_var
		fi
		num=$(($num+1))
	done

}


SCP_instance(){

	gcloud compute --project "caideyi" ssh --zone "asia-east1-b" "evm-lite" -- './TendermintOnEvm_benchmark/scp.sh'
	echo "Transfer done!!"

}

#SCP_instance
success_tx=$(Get_success_tx)
repeat_hash=$(Get_repeat_onetime_tx_hash)
nonce_high_tx=$(Get_nonce_too_high_tx)
total_send=$(Get_request_num)
Statist_Failtx
echo "-----------TestResult---------------" >> $path_report
echo "Success_tx: $success_tx" >> $path_report
echo "Repeat_hash: $repeat_hash" >> $path_report
echo "Nonce Too high: $nonce_high_tx" >> $path_report
echo "Total send: $total_send" >> $path_report
echo $repeat_hash >> $path_fail
Get_tx_rate
PreprocessTxt
CalculateTps
CalculateLatency

