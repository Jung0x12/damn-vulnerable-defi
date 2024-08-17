# Truster

More and more lending pools are offering flashloans. In this case, a new pool has launched that is offering flashloans of DVT tokens for free.

The pool holds 1 million DVT tokens. You have nothing.

To pass this challenge, rescue all funds in the pool executing a single transaction. Deposit the funds into the designated recovery account.

# Solution

### 目標

把 pool 的錢全部轉移到 recovery

### 解析

TrusterLenderPool 的 flashLoan 不是一個遵守 ERC3156 的 flashLoan lender\
所以這個 flashLoan 不會去呼叫 onFlashLoan，取而代之的是讓 caller 自行帶 calldata 去執行動作\

細看 flashLoan 可以發現可以攻擊的點在 
```solidity
target.functionCall(data);
```

我們要利用這個 `target` 執行帶進去的 `data`\
這邊可以做到的，就是 target 帶 `token`，而 data 帶 `approve` 這個 function\
因為 token 是一個 ERC20 所以可以利用他的 approve 先授權，結束 flashLoan 後我們再來轉移

接著看這個 flashLoan 的四個參數
```solidity
function flashLoan(uint256 amount, address borrower, address target, bytes calldata data)
```
- amount: 本題 player 沒有被分配到錢，窮鬼只能帶 0
- borrower: 這個 borrower 基本上是誰不重要，這邊不是下手的重點
- target: 這 target 就是下手重點了，我們要利用 token 的 approve 讓我們自定義的合約 `TrusterSolution` 可以從 pool 轉錢出來，所以這個 target 就是 token
- data: 這邊就是把 approve 這動作用 encode 打包並帶上

最後讓 `TrusterSolution` 執行 token.transferFrom 從 pool 給 recovery

關於 `TrusterSolution`：因為題目限制，只能在一個 tx 完成，所以我們得自己寫一個合約來一次完成這個動作