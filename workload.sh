ResetLogFile(){
	./resetTXT.sh
}

Get_success_tx(){
	success_tx=0
	for line in `cat blockTxNum.txt`
	do
		success_tx=$(($success_tx+$line))
	done
	echo $success_tx
}
Get_repeat_onetime_tx_hash(){
	cat data/hash_tx.txt | grep -o '0x[0-9,a-z]*' >> data/log
	sort data/log |uniq -d >> data/fail_tx
	var=$(cat data/fail_tx | wc -l)
	echo $var
}
Get_nonce_too_high_tx(){
	cat data/hash_tx.txt | grep -o 'nonce too high' >> data/nonceTooHigh
	var=$(cat data/nonceTooHigh | wc -l)
	echo $var
}
Statist_Failtx(){

	num=1
	time=0
	success=true
	txPerBlock=$(sed -n 1p blockTxNum.txt)
	index=1
	for line in `cat data/log`
	do
		success=true
		for line2 in `cat data/fail_tx`
		do
			if [ "$line" = "$line2" ]
			then
				sed -i "/$line2/d" data/fail_tx
				success=false
			fi
		done
		if [ "$success" = true ] 
		then 
			echo "$num : success"
		else
			echo "$num : fail"
			let txPerBlock=txPerBlock+1
		fi
		if [ "$num" -eq "$txPerBlock" ]
		then
			echo "--------------------"
			index=$(($index+1))
			add_var=$(sed -n "$index"p blockTxNum.txt)
			let txPerBlock=txPerBlock+add_var
		fi
		num=$(($num+1))
	done

}

Send_tx(){
	start_time=$( date +%s.%N )
	curl -X POST http://localhost:$4/tx -d '{"from":"'0x$1'","to":"'0x$2'","value":'$3'}' -s
	echo $start_time >> data/txRequestTime.txt
}

WorkLoad(){
	for ((i=0;i<$2;i++)){
		Send_tx d3fe6e278f533c62dc0ffe060af4bb09b79ed0df b2f094f1ba8bbb363c128b37fbe83235b3bfc0a9 1 8080 >> data/hash_tx.txt & 
		sleep $1
		Send_tx d22312c75d4132959777c8d79bf402f31ab688dc 1f3e38f742d9a73483c3f80fdd5d116d61438db5 1 8080 >> data/hash_tx.txt &
		sleep $1
		Send_tx 627575b318b41242dc2661673431f2961e2b2d95 ce69a2fe2b80d05cf0652293acc4dd75bfa06f06 1 8080 >> data/hash_tx.txt &
		sleep $1
		Send_tx 5042458892bf8e7b0865757a2c49dce88792a4bb 2100f32235a599dd1ad6cc24bb54c856a9f12798 1 8080 >> data/hash_tx.txt &
		sleep $1
	}
}

ResetLogFile
start_time=$( date +%s.%N )
WorkLoad $1 $2
elapsed_time=$( date +%s.%N --date="$start_time seconds ago" )
echo "TimeLeft= $elapsed_time"
sleep 1
success_tx=$(Get_success_tx)
repeat_hash=$(Get_repeat_onetime_tx_hash)
nonce_high_tx=$(Get_nonce_too_high_tx)
total_send=$(($2*4))
Statist_Failtx
echo "Success_tx: $success_tx"
echo "Repeat_hash: $repeat_hash"
echo "Nonce Too high: $nonce_high_tx"
echo "Total send: $total_send"

