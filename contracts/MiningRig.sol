// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // For reward tokens like WATT

contract MiningRig is Ownable {
    IERC1155 public nftContract;
    IERC20 public wattToken; // Token used for rewards
    uint256 public totalRigs;

    struct MiningRigStruct {
        address owner;
        uint256[] tokenIds;  // Components (e.g., CPU, GPU)
        uint256 hashrate;
        uint256 wattUsage;
    }

    mapping(address => MiningRigStruct[]) public userRigs;

    // Constructor to initialize the contract with the initial owner and NFT contract
    constructor(IERC1155 _nftContract, IERC20 _wattToken, address initialOwner) Ownable(initialOwner) {
        nftContract = _nftContract;
        wattToken = _wattToken;
    }

    // Function to create a new mining rig
    function createMiningRig(uint256[] memory tokenIds, uint256 hashrate, uint256 wattUsage) external {
        require(tokenIds.length > 0, "You must provide at least one component to create a rig");

        MiningRigStruct memory newRig = MiningRigStruct({
            owner: msg.sender,
            tokenIds: tokenIds,
            hashrate: hashrate,
            wattUsage: wattUsage
        });

        userRigs[msg.sender].push(newRig);
        totalRigs++;
    }

    // Function to get all rigs owned by a user
    function getUserRigs(address user) external view returns (MiningRigStruct[] memory) {
        return userRigs[user];
    }

    // Function to update the mining rig configuration by adding new components
    function updateMiningRig(uint256 rigIndex, uint256[] memory newTokenIds, uint256[] memory boostValues) external {
        MiningRigStruct storage rig = userRigs[msg.sender][rigIndex];
        require(rig.owner == msg.sender, "You are not the owner of this rig");

        require(newTokenIds.length > 0 && newTokenIds.length <= 6, "Invalid number of components");

        uint256 newHashrate = rig.hashrate;
        uint256 newWattUsage = rig.wattUsage;

        for (uint256 i = 0; i < newTokenIds.length; i++) {
            // Logic to adjust hashrate and watt usage based on the new components
            if (newTokenIds[i] == 3) {  // Example for CPU
                newHashrate += 10;
                newWattUsage += 2;
            } else if (newTokenIds[i] == 4) {  // Example for GPU
                newHashrate += 20;
                newWattUsage += 10;
            }

            // Transfer new NFTs to the contract
            nftContract.safeTransferFrom(msg.sender, address(this), newTokenIds[i], 1, "");
        }

        rig.tokenIds = newTokenIds;
        rig.hashrate = newHashrate;
        rig.wattUsage = newWattUsage;
    }

    // Function to transfer ownership of a mining rig
    function transferRigOwnership(uint256 rigIndex, address newOwner) external {
        MiningRigStruct storage rig = userRigs[msg.sender][rigIndex];
        require(rig.owner == msg.sender, "You are not the owner of this rig");

        rig.owner = newOwner;
        userRigs[newOwner].push(rig);

        // Remove rig from sender's ownership after transferring
        delete userRigs[msg.sender][rigIndex];
    }

    // Function to calculate mining rewards based on hashrate
    function calculateMiningRewards(address user, uint256 rigIndex) public view returns (uint256) {
        MiningRigStruct storage rig = userRigs[user][rigIndex];
        uint256 rewards = rig.hashrate * 1e18;  // Example: 1 unit of rewards per hashrate

        return rewards;
    }

    // Function to claim mining rewards
    function claimMiningRewards(uint256 rigIndex) external {
        MiningRigStruct storage rig = userRigs[msg.sender][rigIndex];
        uint256 rewards = calculateMiningRewards(msg.sender, rigIndex);

        require(rewards > 0, "No rewards available");
        wattToken.transfer(msg.sender, rewards);
    }

    // Function to remove NFTs from the mining rig
    function removeNFTs(uint256 rigIndex, uint256[] memory tokenIds) external {
        MiningRigStruct storage rig = userRigs[msg.sender][rigIndex];
        require(rig.owner == msg.sender, "You are not the owner of this rig");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            nftContract.safeTransferFrom(address(this), msg.sender, tokenIds[i], 1, "");
        }

        delete userRigs[msg.sender][rigIndex];
    }
}
