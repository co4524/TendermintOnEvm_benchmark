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


ResetLogFile(){
	./reset.sh
}

Get_tx_rate(){
	end=$(sed -n '$p' $path_txRequestTime)
	start=$(sed -n 1p $path_txRequestTime)
	echo "Send_start_time= $start" #>> Report.txt
	echo "Send_end_time= $end" #>> Report.txt
	time=$(echo "scale=4;$end-$start" | bc)
	tx_rate=$(echo "scale=4;$total_send/$time" | bc)
	echo "tx_rate= $tx_rate"
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
	echo "mod_tx_num= $tx_num"
	echo "start_time= $tx_start_time" #>> Report.txt
	echo "end_time= $commit_time" #>> Report.txt
	total_time=$(echo "scale=4;$commit_time-$tx_start_time" | bc)
	echo "dur_time= $total_time" #>> Report.txt
	tps=$(echo "scale=4;$tx_num/$total_time" | bc)
	echo "TPS =$tps" #>> Report.txt
	#echo $tps #>> tps.txt
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
	echo "AvgLatencyTime= $avg_latency" #>> Report.txt
	#echo $avg_latency >> latency.txt

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
			echo "$num : success"
			echo T >> $path_tf
		else
			echo "$num : fail"
			echo F >> $path_tf
			let txPerBlock=txPerBlock+1
		fi
		if [ "$num" -eq "$txPerBlock" ]
		then
			echo "--------------------"
			index=$(($index+1))
			add_var=$(sed -n "$index"p $path_blockTxNum)
			let txPerBlock=txPerBlock+add_var
		fi
		num=$(($num+1))
	done

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
		Send_tx b2f094f1ba8bbb363c128b37fbe83235b3bfc0a9 1f3e38f742d9a73483c3f80fdd5d116d61438db5 1 $3 >> $path_rawData &
		sleep $1
		Send_tx d22312c75d4132959777c8d79bf402f31ab688dc ce69a2fe2b80d05cf0652293acc4dd75bfa06f06 1 $3 >> $path_rawData &
		sleep $1
		Send_tx 1f3e38f742d9a73483c3f80fdd5d116d61438db5 2100f32235a599dd1ad6cc24bb54c856a9f12798 1 $3 >> $path_rawData &
		sleep $1
	}
}

SCP_instance(){

	gcloud compute --project "caideyi" ssh --zone "asia-east1-b" "evm-lite" -- './TendermintOnEvm_benchmark/scp.sh'
	echo "Transfer done!!"

}

ResetLogFile
start_time=$( date +%s.%N )
WorkLoad $1 $2 $3
elapsed_time=$( date +%s.%N --date="$start_time seconds ago" )
echo "TimeLeft= $elapsed_time"
sleep 2
#SCP_instance
success_tx=$(Get_success_tx)
repeat_hash=$(Get_repeat_onetime_tx_hash)
nonce_high_tx=$(Get_nonce_too_high_tx)
total_send=$(Get_request_num)
Statist_Failtx
echo "Success_tx: $success_tx"
echo "Repeat_hash: $repeat_hash"
echo "Nonce Too high: $nonce_high_tx"
echo "Total send: $total_send"
Get_tx_rate
PreprocessTxt
CalculateTps
CalculateLatency
