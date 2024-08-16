# Naive Receiver

There’s a pool with 1000 WETH in balance offering flash loans. It has a fixed fee of 1 WETH. The pool supports meta-transactions by integrating with a permissionless forwarder contract. 

A user deployed a sample contract with 10 WETH in balance. Looks like it can execute flash loans of WETH.

All funds are at risk! Rescue all WETH from the user and the pool, and deposit it into the designated recovery account.

# Solution

### 目標

把 pool 和 receiver 的 eth 都搬到 recovery

### 解析

NaiveReceiverPool 初始有 1000 eth\
細看 NaiveReceiverPool 在 constructor 內執行 `_deposit()` 時\
會發現初始化的 1000 eth 會存放在 `msgSender` 底下，在本測試中就是 `deployer`\
而 constructor 的 `_feeReceiver` 在本測試也是 `deployer`，也就是說初始 1000 eth + 之後的每一筆 fee 都會跑到 deployer 底下

FlashLoanReceiver 初始有 10 eth\
FlashLoanReceiver 的 `onFlashLoan` 會在 NaiveReceiverPool 執行 `flashLoan` 時 callback 呼叫到\
通常 onFlashLoan 這段是收到 flashLoan 的錢後，要執行的騷操作都在這邊發生\
一波騷操作結束後會 `approve` NaiveReceiverPool 取回借出的 loan 外加 fee

這題的 fee 一次是 1 eth，也就是說我們要連續操作 10 次才能把 FlashLoanReceiver 的錢給全部移動到 NaiveReceiverPool\
而移動到 NaiveReceiverPool 後就會歸到 _feeReceiver 底下，也就是前面提到是本題的 deployer\
最後在執行 NaiveReceiverPool 的 `withdraw` 就可以把 msgSender 的錢給取出來，還給救援帳戶 `recovery`\

關鍵在於要怎麼讓 `msgSender` 變成 `deployer`？ 這邊細看 NaiveReceiverPool 的 `_msgSender()` 是一個 custom 判斷 caller 的方法\
如果 caller 是 `trustedForwarder` 而且 data 長度大於 20，那就會截斷 data，取後面 20 bytes 的長度，20 bytes 剛好就是地址的長度\
所以我們要在打包 withdrwal 的 calldata 時，後面帶上 deployer 的地址\

因為題目限制只能在兩個 nonce 完成，所以這邊就需要借助 NaiveReceiverPool 內的 Multicall 來把要做的事情打包起來，在一次呼叫\
所以實作上，會是以下步驟
1. 宣告一個長度 11 的 bytes 陣列，前 10 個是做 flashLoan 慢慢把 FlashLoanReceiver 的錢轉到 NaiveReceiverPool\
   第 11 個是去 NaiveReceiverPool 執行 withdraw 把錢領出來，並且要把 deployer 的地址從後面一起打包進去，才能操控 _msgSender()
2. calldatas 組好之後，在去把它打包成呼叫 NaiveReceiverPool 內的 Multicall
3. 接下來就是處理 meta-transaction 內簽名的部分
4. 最後執行攻擊

### 補充
關於 `_msgSender()`\
這邊看到 `msg.data[msg.data.length - 20:]` 這邊用了 slice 的表達式，取出 `msg.data.length - 20` 後面的資料

```solidity
function _msgSender() internal view override returns (address) {
    if (msg.sender == trustedForwarder && msg.data.length >= 20) {
        return address(bytes20(msg.data[msg.data.length - 20:]));
    } else {
        return super._msgSender();
    }
}
```

### 參考

Solution\
https://medium.com/@opensiddhu993/challenge-2-naive-receiver-damn-vulnerable-defi-v4-lazy-solutions-series-8b3b28bc929d

Slice\
https://www.whatsweb3.org/docs/solidity-basic/array-slice