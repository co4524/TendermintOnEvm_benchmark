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
0.35
0.24499999999999997
0.17149999999999996
0.12004999999999996
0.08403499999999997
0.058824499999999974
0.04117714999999998
0.028824004999999986
0.02017680349999999
0.014123762449999992
0.009886633714999994
0.006920643600499995
0.004844450520349996
0.003391115364244997
0.002373780754971498
0.0016616465284800485
0.001163152569936034
0.0008142067989552236
0.0001368437367004044
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
		./Performance.sh $i 3 $1 $2 1
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
		./Performance.sh $i ${batchNum[$index]} $1 $2 10
		##[1]:sleep time  [2]:iteration time  [3]:ip address [4]:instance_name [5]:重複測試次數
		let index=index+1
	done

}

ResetReport
SpeedTest $1 $2
sleep 3
ResetReport
Benchmark $1 $2
