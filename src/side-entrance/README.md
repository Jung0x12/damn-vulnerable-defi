# Side Entrance

A surprisingly simple pool allows anyone to deposit ETH, and withdraw it at any point in time.

It has 1000 ETH in balance already, and is offering free flashloans using the deposited ETH to promote their system.

Yoy start with 1 ETH in balance. Pass the challenge by rescuing all ETH from the pool and depositing it in the designated recovery account.

# Solution

### 目標

把 pool 的 ETH 轉給 revcovery

### 解析

SideEntranceLenderPool 不是實作 ERC3156 的 flashLoan lender\
執行 flashLoan 時會去呼叫 IFlashLoanEtherReceiver 合約的 execute\
並且在最後只用 `address(this).balance < balanceBefore` 判斷有沒有歸還\
這個判斷意味著，只要有把錢給放進來就好，無論擁有者是誰\

接著看 SideEntranceLenderPool 的 deposit\
前面提到 flashLoan 最後的判斷只要把錢放進來就好\
所以可以利用這個 deposit 來轉移擁有者給自己，反正最後錢都有進來\

最後再利用 SideEntranceLenderPool 的 withdraw 把錢轉出來\
然後在給 recovery

### 參考

solution\
https://medium.com/@opensiddhu993/challenge-4-side-entrance-damn-vulnerable-defi-v4-lazy-solutions-series-b19a01aab66e