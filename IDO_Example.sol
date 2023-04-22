// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract IDO is Ownable, ReentrancyGuard {
    uint256 public price;
    uint256 public totalTokens;
    uint256 public tokensSold;
    uint256 public tokensLocked;
    uint256 public limitPerWallet;
    using ECDSA for bytes32;
    IERC20 importToken;
    bytes32 private merkleRoot;
    bool public presaleStarted;
    bool public publicSaleStarted;

    event Freeze(uint256 count);
    event Sale(uint256 count, address holder);

    constructor(uint256 _totalTokens, address _importToken, uint256 _price) {
        totalTokens = _totalTokens;
        importToken = IERC20(_importToken);
        price = _price;
        limitPerWallet = totalTokens;
    }

    //Core
    
    function buy(uint256 amount) public payable nonReentrant {
        require(publicSaleStarted, "Public sale hasn't started yet");
        uint256 value = msg.value;
        require(price * amount == value, "Wrong value");
        require(amount + tokensSold <= totalTokens - tokensLocked, "Exceeded amount of tokens");
        require(importToken.balanceOf(msg.sender) + amount <= limitPerWallet, "Exceeded wallet limit");
        importToken.transfer(msg.sender, amount);
        tokensSold += amount;
        emit Sale(amount, msg.sender);
    }

    function presale(uint256 amount, bytes32[] calldata _merkleProof) public payable nonReentrant {
        require(presaleStarted, "Presale hasn't started yet");
        uint256 value = msg.value;
        require(price * amount == value, "Wrong value");
        require(amount + tokensSold <= totalTokens - tokensLocked, "Exceeded amount of tokens");
        require(importToken.balanceOf(msg.sender) + amount <= limitPerWallet, "Exceeded wallet limit");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Presale must be minted from our website");
        importToken.transfer(msg.sender, amount);
        tokensSold += amount;
        emit Sale(amount, msg.sender);
    }

    //Settings

    function freeze(uint256 amount) public onlyOwner {
        require(amount <= totalTokens - tokensSold);
        tokensLocked += amount;
        emit Freeze(amount);
    }

    function setPrice(uint256 _newPrice) public onlyOwner {
        price = _newPrice;
    }

    function setMerkleRoot(bytes32 _newRoot) public onlyOwner {
        merkleRoot = _newRoot;
    }

    function setWalletLimit(uint256 amount) public onlyOwner {
        require(limitPerWallet <= totalTokens - tokensSold);
        limitPerWallet = amount;
    }

    function togglePublicSaleStarted() external onlyOwner {
        require(importToken.balanceOf(address(this)) > 0, "There are 0 tokens to sell");
        publicSaleStarted = !publicSaleStarted;
    }

    function togglePresaleStarted() external onlyOwner {
        require(importToken.balanceOf(address(this)) > 0, "There are 0 tokens to sell");
        presaleStarted = !presaleStarted;
    }

    function checkBalance() public view returns (uint256) {
        return importToken.balanceOf(address(this));
    }

    // Withdraw

    function withdrawAll(address owner) public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Insufficent balance");
        _widthdraw(owner, address(this).balance);
    }

    function withdrawPart(uint256 amount, address owner) public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Insufficent balance");
        _widthdraw(owner, amount);
    }

    function _widthdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{ value: _amount }("");
        require(success, "Failed to widthdraw Ether");
    }
}