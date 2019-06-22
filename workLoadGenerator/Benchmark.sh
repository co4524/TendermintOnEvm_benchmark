path2=$HOME/TendermintOnEvm_benchmark/report
path_report=$path2/report
path_avg_tps=$path2/tps
path_avg_latency=$path2/latency
path_avg_txRate=$path2/txRate
path_avg_fail=$path2/fail
################################
ip=localhost
threadNum=1  #concurent num
nodeNum=1    #workload Send txNum
txTime=5   #test time
batchNum=0

array=(
200
140.0
98.0
68.6
48.02
33.614
23.5298
16.47086
11.529602
8.0707214
5.64950498
3.954653486
2.7682574402
1.93778020814
0.949512301989
0.325682719582
0.111709172817
0.0383162462761
)

ResetReport(){
	rm $path_avg_tps
	rm $path_avg_latency
	rm $path_avg_txRate
	rm $path_avg_fail
	rm $path_report
	touch $path_avg_tps
	touch $path_avg_latency
	touch $path_avg_txRate
	touch $path_avg_fail
	touch $path_report
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
	for i in "${array[@]}"
	do
		./Performance.sh $i ${batchNum[$index]} 10 $1
		##[1]:sleep time  [2]:iteration time  [3]:ip address [4]:instance_name [5]:重複測試次數
		let index=index+1
	done

}

ResetReport
SpeedTest $1
sleep 3
ResetReport
Benchmark $1
