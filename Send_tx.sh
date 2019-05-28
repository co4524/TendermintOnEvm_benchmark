start_time=$( date +%s.%N )
curl -X POST http://localhost:$4/tx -d '{"from":"'0x$1'","to":"'0x$2'","value":'$3'}' -s
echo $start_time >> data/txRequestTime.txt
