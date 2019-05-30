remote_path=/home/caideyi/TendermintOnEvm_benchmark/data
data_path1=$HOME/TendermintOnEvm_benchmark/data/blockCommitTime.txt
data_path2=$HOME/TendermintOnEvm_benchmark/data/blockTxNum.txt
sshpass -p monkey456 scp -P 50222 $data_path1 caideyi@140.112.29.207:$remote_path
sshpass -p monkey456 scp -P 50222 $data_path2 caideyi@140.112.29.207:$remote_path
rm $data_path1
rm $data_path2
touch $data_path1
touch $data_path2
