# Unstoppable

There's a tokenized vault with a million DVT tokens deposited. It’s offering flash loans for free, until the grace period ends.

To catch any bugs before going 100% permissionless, the developers decided to run a live beta in testnet. There's a monitoring contract to check liveness of the flashloan feature.

Starting with 10 DVT tokens in balance, show that it's possible to halt the vault. It must stop offering flash loans.

# Solution

The key vulnerability is found in the `flashLoan` function in `UnstoppableVault`.

```
uint256 balanceBefore = totalAssets();
if (convertToShares(totalSupply) != balanceBefore) revert InvalidBalance(); // enforce ERC4626 requirement
```

To make `convertToShares(totalSupply)` not equal to `balanceBefore`, we can directly donate asset to this vault.

After donation, `totalAssets()` will increase but `totalSupply` will still remaning the same,\
cuz `totalSupply` will only increase when someone come to deposite to the vault.

