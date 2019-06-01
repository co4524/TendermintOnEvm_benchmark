path_blockTxNum="/home/caideyi/TendermintOnEvm_benchmark/data/blockTxNum.txt"
path_txRequestTime="/home/caideyi/TendermintOnEvm_benchmark/data/txRequestTime.txt"
path_preCommitTime="/home/caideyi/TendermintOnEvm_benchmark/data/pre_BlockCommitTime.txt"
path_tf="/home/caideyi/TendermintOnEvm_benchmark/data/tf"
## Open file
fp_blockTxNum = open(path_blockTxNum, "r")
fp_txRequestTime = open(path_txRequestTime, "r")
fp_preCommitTime = open(path_preCommitTime, "r")
fp_tf = open(path_tf, "r")
 
blockTxNum = fp_blockTxNum.readlines()
txRequestTime = fp_txRequestTime.readlines()
preCommitTime = fp_preCommitTime.readlines()
tf = fp_tf.readlines()

# close file
fp_blockTxNum.close()
fp_txRequestTime.close()
fp_preCommitTime.close()
fp_tf.close()

tmp=0
sum=0
suc_tx=0

for i in range(len(tf)):
    txNum=int(blockTxNum[tmp])
    if(tf[i] == 'T\n' or tf[i] == 'T'):
        suc_tx+=1
        ct=float(preCommitTime[tmp])
        rt=float(txRequestTime[i])
        lat=ct-rt
        sum=sum+float(lat)
        blockTxNum[tmp]=int(blockTxNum[tmp])-1
        if(blockTxNum[tmp]==0):
            tmp=tmp+1
        if(tmp==len(blockTxNum)):
            break


print(sum/suc_tx)
