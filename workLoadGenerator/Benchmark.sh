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
10
5
2.5
1.666666667
1.25
1
0.8333333333
0.7142857143
0.625
0.5555555556
0.5
0.4545454545
0.4166666667
0.3846153846
0.3571428571
0.3333333333
0.3125
0.2941176471
0.2777777778
0.2631578947
0.25
0.2380952381
0.2272727273
0.2173913043
0.2083333333
0.2
0.1923076923
0.1851851852
0.1785714286
0.1724137931
0.1666666667
)

txTotalSend=(
500
1000
2000
3000
4000
5000
6000
7000
8000
9000
10000
11000
12000
13000
14000
15000
16000
17000
18000
19000
20000
21000
22000
23000
24000
25000
26000
27000
28000
29000
30000
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
