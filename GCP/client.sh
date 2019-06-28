echo Transfer Done >> 123
remote_path=/home/caideyi/TendermintOnEvm_benchmark
sshpass -p monkey456 scp -P 50222 123 caideyi@140.112.29.207:$remote_path
