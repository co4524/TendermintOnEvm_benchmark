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
0.00075
0.0005
0.00025
0.000125
0.000075
0.00005
0.000025
0.00001
)

for i in "${array[@]}"
do
	./Performance.sh $i 300
done
