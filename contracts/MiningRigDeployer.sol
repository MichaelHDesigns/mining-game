// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MiningRigDeployer is Ownable {
    IERC1155 public nftContract;

    // Constructor accepting the NFT contract address and the initial owner's address
    constructor(IERC1155 _nftContract) Ownable(msg.sender) {
        nftContract = _nftContract;
    }
}