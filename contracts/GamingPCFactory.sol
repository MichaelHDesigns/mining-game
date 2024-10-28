// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract GamingPCFactory is Ownable {
    IERC1155 public nftContract;
    uint256 public totalGamingPCs;

    struct GamingPC {
        address owner;
        uint256[] componentIds;  // Components (e.g., CPU, GPU)
        uint256 hashrate;
        uint256 wattUsage;
    }

    mapping(address => GamingPC[]) public userGamingPCs;

    constructor(IERC1155 _nftContract, address initialOwner) Ownable(initialOwner) {
        nftContract = _nftContract;
    }

    // Function to create a Gaming PC
    function createGamingPC(uint256[] memory componentIds, uint256 hashrate, uint256 wattUsage) external {
        require(componentIds.length > 0, "At least one component is required");

        GamingPC memory newPC = GamingPC({
            owner: msg.sender,
            componentIds: componentIds,
            hashrate: hashrate,
            wattUsage: wattUsage
        });

        userGamingPCs[msg.sender].push(newPC);
        totalGamingPCs++;
    }

    // Function to get all PCs owned by a user
    function getUserGamingPCs(address user) external view returns (GamingPC[] memory) {
        return userGamingPCs[user];
    }

    // Function to remove a component from a gaming PC
    function removeComponentsFromPC(uint256 pcIndex, uint256 componentId) external {
        require(pcIndex < userGamingPCs[msg.sender].length, "Invalid PC index");
        GamingPC storage pc = userGamingPCs[msg.sender][pcIndex];
        require(pc.owner == msg.sender, "You are not the owner of this PC");

        // Remove component
        uint256 index;
        bool found = false;
        for (uint256 i = 0; i < pc.componentIds.length; i++) {
            if (pc.componentIds[i] == componentId) {
                index = i;
                found = true;
                break;
            }
        }
        require(found, "Component not found");

        pc.componentIds[index] = pc.componentIds[pc.componentIds.length - 1]; // Replace with last element
        pc.componentIds.pop();  // Remove last element

        if (pc.componentIds.length == 0) {
            // Remove the PC from the user's list if there are no components left
            delete userGamingPCs[msg.sender][pcIndex];
        }
    }
}
