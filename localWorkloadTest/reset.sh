path=$HOME/TendermintOnEvm_benchmark/data
path_blockTxNum=$path/blockTxNum.txt
path_blockCommitTime=$path/blockCommitTime.txt
path_txRequestTime=$path/txRequestTime.txt
path_rawData=$path/rawData
path_log=$path/log
path_repeatHash=$path/repeatHash
path_nonce=$path/nonceTooHigh
path_preCommitTime=$path/pre_BlockCommitTime.txt
path_tf=$path/tf

#rm pro_BlockCommitTime.txt
#touch pro_BlockCommitTime.txt
rm $path_blockTxNum
rm $path_blockCommitTime
rm $path_txRequestTime
rm $path_rawData
rm $path_log
rm $path_repeatHash
rm $path_nonce
rm $path_preCommitTime
rm $path_tf
#################################
touch $path_blockTxNum
touch $path_blockCommitTime
touch $path_txRequestTime
touch $path_rawData
touch $path_log
touch $path_repeatHash
touch $path_nonce
touch $path_preCommitTime
touch $path_tf