path2=$HOME/TendermintOnEvm_benchmark/report
path_report=$path2/report
path_avg_tps=$path2/tps
path_avg_latency=$path2/latency
path_avg_txRate=$path2/txRate
path_avg_fail=$path2/fail

path_var_tps=$path2/vTps
path_var_latency=$path2/vLatency
path_var_txRate=$path2/vTxRate

################################
ip=localhost
threadNum=1  #concurent num
nodeNum=1    #workload Send txNum
txTime=5   #test time
batchNum=0

intervalTime=(
60.24096386
30.12048193
15.01501502
10
7.507507508
6.00240096
5
4.288164666
3.750937734
3.333333333
3.00120048
2.727768685
2.5
2.308402585
2.143163309
2
1.875468867
1.764913519
1.666666667
1.579279848
1.500150015
1.428571429
1.363884343
1.304461258
1.25
1.200192031
1.153934918
1.111111111
1.071581655
1.034554107
1
)

txTotalSend=(
83
166
333
500
666
833
1000
1166
1333
1500
1666
1833
2000
2166
2333
2500
2666
2833
3000
3166
3333
3500
3666
3833
4000
4166
4333
4500
4666
4833
5000
)

ResetReport(){
	rm $path_avg_tps
	rm $path_avg_latency
	rm $path_avg_txRate
	rm $path_report
	rm $path_var_tps
	rm $path_var_latency
	rm $path_var_txRate
	touch $path_avg_tps
	touch $path_avg_latency
	touch $path_avg_txRate
	touch $path_report
	touch $path_var_tps
	touch $path_var_latency
	touch $path_var_txRate
}

SpeedTest(){

	for i in "${array[@]}"
	do
		./Performance.sh $i 50 1 $1
		##[1]:sleep time  [2]:iteration time  [3]:ip address [4]:instance_name [5]:重複測試次數
	done

	index=0
	while read line; 
	do
   		VARS[$index]="$line"
   		index=`expr $index + 1`

	done < $path_avg_txRate

	for ((index=0; index<${#VARS[@]}; index++)); 
	do
   		#echo "[$index]: ${VARS[$index]}"
		batchNum[$index]=$(echo "scale = 0; ${VARS[$index]}*$txTime/$threadNum/$nodeNum" | bc -l)
		echo "[$index]: ${batchNum[$index]}"
	done

}

Benchmark() {

	index=0
	for i in "${intervalTime[@]}"
	do
		./Performance.sh $i ${txTotalSend[$index]} $1 $2
		#[1]:interval time 
		#[2]:total send  
		#[3]:iter 
		#[4]:instance_name 
		let index=index+1
	done

}

ResetReport
Benchmark $1 $2
#[1]:iter
#[2]:instance_name
