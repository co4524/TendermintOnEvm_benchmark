package tendermint

import (
	"encoding/hex"
	"time"
	"github.com/bear987978897/evm-lite/src/state"
	"github.com/ethereum/go-ethereum/common"
	"github.com/sirupsen/logrus"
	"github.com/tendermint/tendermint/abci/types"
	"fmt"
	"os"
)

var path1 = "/home/caideyi/TendermintOnEvm_benchmark/data/blockCommitTime.txt"
var path2 = "/home/caideyi/TendermintOnEvm_benchmark/data/blockTxNum.txt"

type ABCIProxy struct {
	types.BaseApplication

	state     *state.State
	logger    *logrus.Entry
	blockHash common.Hash
	txIndex   int
}

func NewABCIProxy(
	state *state.State,
	logger *logrus.Logger,
) *ABCIProxy {
	return &ABCIProxy{
		state:     state,
		logger:    logger.WithField("module", "tendermint/abci"),
		blockHash: common.Hash{},
		txIndex:   0,
	}
}

/********************************************************
Implement Tendermint ABCI application
*********************************************************/
func (p *ABCIProxy) BeginBlock(req types.RequestBeginBlock) types.ResponseBeginBlock {
	p.blockHash = common.BytesToHash(req.Hash)

	p.logger.Debug("Begin block: ", p.blockHash.String())

	return types.ResponseBeginBlock{}
}

func (p *ABCIProxy) DeliverTx(tx []byte) types.ResponseDeliverTx {
	err := p.state.ApplyTransaction(tx, p.txIndex, p.blockHash)
	if err != nil {
		p.logger.Panic("DeliverTx Error: ", err)
		return types.ResponseDeliverTx{Code: 1}
	}
	p.txIndex++
	dst := make([]byte, hex.DecodedLen(len(tx)))
	txHex, _ := hex.Decode(dst, tx)

	p.logger.Debug("DeliverTx: ", txHex)

	return types.ResponseDeliverTx{Code: types.CodeTypeOK}
}

func (p *ABCIProxy) Commit() types.ResponseCommit {


	hash, err := p.state.Commit()

	if err != nil {
		p.logger.Panic("Commit Error: ", err)
		return types.ResponseCommit{}
	}
	p.logger.Debug("Block commited: ", hash)

	if p.txIndex != 0 {

		m := makeTimestampMilli()
		file, err1 := os.OpenFile(path1, os.O_APPEND|os.O_WRONLY, 0600)
		file2, err2 := os.OpenFile(path2, os.O_APPEND|os.O_WRONLY, 0600)
		if err1 != nil {
			p.logger.Panic("File Error: ",err1)
			return types.ResponseCommit{}
		}
		if err2 != nil {
			p.logger.Panic("File2 Error: ",err2)
			return types.ResponseCommit{}
		}
		defer file.Close()
		defer file2.Close()
		file2.WriteString(fmt.Sprintf("%d\n",p.txIndex))
		file.WriteString(fmt.Sprintf("%d\n", m))

	}
	m := makeTimestampMilli()
	p.logger.Debug("Time: ",time.Unix(m/1e3, (m%1e3)*int64(time.Millisecond)/int64(time.Nanosecond)))
	p.txIndex = 0
	return types.ResponseCommit{}
}

func unixMilli(t time.Time) int64 {
	return t.Round(time.Millisecond).UnixNano() / (int64(time.Millisecond) / int64(time.Nanosecond))
}

func makeTimestampMilli() int64 {
	return unixMilli(time.Now())
}
