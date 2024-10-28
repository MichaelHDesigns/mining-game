// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MiningRigFactory is Ownable {
    IERC1155 public nftContract; // Reference to the NFT contract for CPU and GPUs
    IERC20 public wattToken;     // WATT token contract
    address public poolAddress;  // Address where mining rewards are sent

    // Token IDs for specific NFTs
    uint256 public constant XL1_CPU_ID = 3;
    uint256 public constant TX120_GPU_ID = 4;
    uint256 public constant GP50_GPU_ID = 5;

    struct MiningRig {
        address owner;
        uint256 cpuId;
        uint256[] gpuIds;
        uint256 hashrate;
        uint256 wattUsage;
    }

    mapping(address => MiningRig) public miningRigs;
    uint256 public totalHashrate; // Total hashrate of all rigs in the pool
    address[] public userAddresses; // To keep track of all user addresses

    event RigDeployed(address indexed user, uint256 cpuId, uint256[] gpuIds);
    event RewardsDistributed(address indexed user, uint256 rewardAmount);

    constructor(IERC1155 _nftContract, IERC20 _wattToken, address _poolAddress) Ownable(msg.sender) {
        nftContract = _nftContract;
        wattToken = _wattToken;
        poolAddress = _poolAddress;
    }

    // Deploy a new Free Gaming PC NFT with 1 CPU and up to 6 GPUs
    function deployRig(uint256 cpuId, uint256[] memory gpuIds) external {
        require(cpuId == XL1_CPU_ID, "You need to use XL1 Processor (Token ID: 3)");
        require(gpuIds.length > 0 && gpuIds.length <= 6, "You must select between 1 and 6 GPUs");

        uint256 tempHashrate = 0;
        uint256 totalWATTUsage = 0;

        // Calculate total hashrate and WATT usage
        for (uint256 i = 0; i < gpuIds.length; i++) {
            uint256 gpuId = gpuIds[i];
            if (gpuId == TX120_GPU_ID) {
                // TX120 GPU
                tempHashrate += 20;
                totalWATTUsage += 10;
            } else if (gpuId == GP50_GPU_ID) {
                // GP50 GPU
                tempHashrate += 33;
                totalWATTUsage += 16;
            } else {
                revert("Invalid GPU token ID");
            }
        }

        // Add CPU stats
        tempHashrate += 10; // Hashrate for XL1 CPU
        totalWATTUsage += 2; // WATT usage for XL1 CPU

        // Transfer NFTs to the contract (stake them)
        nftContract.safeTransferFrom(msg.sender, address(this), cpuId, 1, ""); // CPU
        for (uint256 i = 0; i < gpuIds.length; i++) {
            nftContract.safeTransferFrom(msg.sender, address(this), gpuIds[i], 1, ""); // GPUs
        }

        // Store the rig's configuration
        miningRigs[msg.sender] = MiningRig({
            owner: msg.sender,
            cpuId: cpuId,
            gpuIds: gpuIds,
            hashrate: tempHashrate,
            wattUsage: totalWATTUsage
        });

        totalHashrate += tempHashrate; // Increase pool hashrate
        userAddresses.push(msg.sender); // Track user address

        emit RigDeployed(msg.sender, cpuId, gpuIds);
    }

    // Calculate the daily WATT usage for the mining rig
    function calculateDailyWATT(address user) external view returns (uint256) {
        MiningRig memory rig = miningRigs[user];
        require(rig.owner == user, "No mining rig found for this address");

        uint256 dailyWATTUsage = rig.wattUsage * 24; // WATT usage per day

        return dailyWATTUsage;
    }

    // Distribute block rewards based on the percentage of the pool's hashrate
    function distributeRewards() external onlyOwner {
        uint256 poolBalance = wattToken.balanceOf(poolAddress);

        for (uint256 i = 0; i < userAddresses.length; i++) {
            address userAddress = userAddresses[i];
            MiningRig memory rig = miningRigs[userAddress];
            if (rig.hashrate > 0) {
                uint256 userReward = (rig.hashrate * poolBalance) / totalHashrate;
                wattToken.transferFrom(poolAddress, userAddress, userReward);
                emit RewardsDistributed(userAddress, userReward);
            }
        }
    }
}
