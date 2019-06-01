remote_path=/home/caideyi/TendermintOnEvm_benchmark/data
data_path1=$HOME/TendermintOnEvm_benchmark/data/blockCommitTime.txt
data_path2=$HOME/TendermintOnEvm_benchmark/data/blockTxNum.txt
gcloud compute scp $data_path1 workloadgenerator:$remote_path --zone asia-east1-b
gcloud compute scp $data_path2 workloadgenerator:$remote_path --zone asia-east1-b
rm $data_path1
rm $data_path2
touch $data_path1
touch $data_path2
