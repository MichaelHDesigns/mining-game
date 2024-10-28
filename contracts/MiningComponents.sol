// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MiningComponents is ERC1155, Ownable {
    uint256 public constant XL1_CPU = 1;
    uint256 public constant TX120_GPU = 2;
    uint256 public constant GP50_GPU = 3;

    constructor(address initialOwner) ERC1155("https://your-api-url.com/{id}.json") Ownable(initialOwner) {
        _mint(initialOwner, XL1_CPU, 100, "");
        _mint(initialOwner, TX120_GPU, 200, "");
        _mint(initialOwner, GP50_GPU, 300, "");
    }

    function mint(address to, uint256 id, uint256 amount, bytes memory data) public onlyOwner {
        _mint(to, id, amount, data);
    }
}
