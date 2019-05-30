path2=$HOME/TendermintOnEvm_benchmark/report
path_report=$path2/report
path_avg_tps=$path2/tps
path_avg_latency=$path2/latency
path_avg_txRate=$path2/txRate
path_avg_fail=$path2/fail
################################
ip=localhost
threadNum=2  #concurent num
nodeNum=4    #workload Send txNum
txTime=5   #test time
batchNum=0

array=(
0.5
0.4
0.3
0.2
0.1
0.075
0.05
0.025
0.01
0.0075
0.005
0.0025
0.001
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
		./Performance.sh $i 3 1
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
		./Performance.sh $i ${batchNum[$index]} 10
		let index=index+1
	done

}

ResetReport
SpeedTest
sleep 3
ResetReport
Benchmark
