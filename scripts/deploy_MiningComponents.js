// scripts/deploy_MiningComponents.js

const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const MiningComponents = await ethers.getContractFactory("MiningComponents");

    // Pass the deployer address to the constructor
    const miningComponents = await MiningComponents.deploy(deployer.address);

    await miningComponents.deployed();
    console.log("MiningComponents deployed to:", miningComponents.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });