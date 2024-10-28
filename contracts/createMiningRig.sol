// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MiningRigDeployer is Ownable {
    IERC1155 public nftContract;  // The contract for the NFTs (CPU, GPU)
    uint256 public totalRigs;

    struct MiningRig {
        address owner;
        uint256[] tokenIds;  // NFTs staked in the rig (1 CPU, up to 6 GPUs)
        uint256 hashrate;    // Total hashrate of the rig
        uint256 wattUsage;   // Total WATT consumption
    }

    mapping(address => MiningRig[]) public userRigs;

    // Define token IDs for CPU and GPUs (based on your actual IDs)
    uint256 public constant XL1_CPU_ID = 3;
    uint256 public constant TX120_GPU_ID = 4;
    uint256 public constant GP50_GPU_ID = 5;

    // Update constructor to accept the initial owner's address
    constructor(IERC1155 _nftContract) Ownable(msg.sender) {
        nftContract = _nftContract;
    }

    // Function to create a new mining rig with NFTs
    function createMiningRig(uint256[] memory tokenIds, uint256[] memory boosts) external {
        require(tokenIds.length > 0 && tokenIds.length <= 7, "You must stake between 1 and 7 NFTs (1 CPU + up to 6 GPUs)");

        uint256 totalHashrate = 0;
        uint256 totalWATTUsage = 0;

        // Verify that the user is staking 1 CPU and up to 6 GPUs
        bool hasCPU = false;
        uint256 gpuCount = 0;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (tokenIds[i] == XL1_CPU_ID) {
                require(!hasCPU, "You can only stake 1 CPU");
                hasCPU = true;
                totalHashrate += 10;  // Example hashrate for XL1 CPU
                totalWATTUsage += 2;  // Example WATT usage for XL1 CPU
            } else if (tokenIds[i] == TX120_GPU_ID) {
                require(gpuCount < 6, "You can only stake up to 6 GPUs");
                gpuCount++;
                totalHashrate += 20;  // Example hashrate for TX120 GPU
                totalWATTUsage += 10; // Example WATT usage for TX120 GPU
            } else if (tokenIds[i] == GP50_GPU_ID) {
                require(gpuCount < 6, "You can only stake up to 6 GPUs");
                gpuCount++;
                totalHashrate += 33;  // Example hashrate for GP50 GPU
                totalWATTUsage += 16; // Example WATT usage for GP50 GPU
            } else {
                revert("Invalid NFT token ID");
            }

            // Transfer the NFTs to this contract to lock them in the mining rig
            nftContract.safeTransferFrom(msg.sender, address(this), tokenIds[i], 1, "");
        }

        // Ensure that exactly 1 CPU is staked
        require(hasCPU, "You must stake exactly 1 CPU");

        // Store the mining rig configuration
        userRigs[msg.sender].push(MiningRig({
            owner: msg.sender,
            tokenIds: tokenIds,
            hashrate: totalHashrate,
            wattUsage: totalWATTUsage
        }));

        totalRigs++;
    }

    // Function to get the rigs owned by a user
    function getUserRigs(address user) external view returns (MiningRig[] memory) {
        return userRigs[user];
    }

    // Function to remove NFTs from the Mining Rig
    function removeNFTs(uint256[] memory tokenIds) external {
        MiningRig[] storage rigs = userRigs[msg.sender];
        require(rigs.length > 0, "No rigs found");

        // Logic to remove NFTs from the rig and transfer them back to the user
        for (uint256 i = 0; i < tokenIds.length; i++) {
            nftContract.safeTransferFrom(address(this), msg.sender, tokenIds[i], 1, "");
        }
    }
}