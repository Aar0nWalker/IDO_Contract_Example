# IDO_Contract_Example

<p align="left">
  <img src="https://img.shields.io/badge/Solidity-0.8.19-informational" alt="Solidity Version">
  <img src="https://img.shields.io/badge/License-MIT-success" alt="License">
</p>
  
<h3>About</h3>

There is a simple IDO template for selling ERC20 tokens for native tokens. Contract provides these functions: public sale, presale (whitelist), token lockup (freeze), personal cap (wallet limit), price changing, presale and public sale switch, partial and full funds withdrawal.

<h3>Core stuff</h3>

To sell some tokens we need to import it through the ERC20 interface (IERC20). For the cheapest whitelist implementation (off-chain) I have used merkle tree and ECDSA to verify leaves. Also, we need to transfer sellable tokens to contract in the same amount as "totalTokens" variable.

<h3>To do:</h3>

- Add audit report
- Add merkle proof web2 example script
- Add tests
- Gas optimisation
- Add custom token selling (USDT, BUSD, etc.)
