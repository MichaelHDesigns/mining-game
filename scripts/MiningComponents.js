const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();

    // Deploy MiningComponents with deployer as the initial owner
    const MiningComponents = await hre.ethers.getContractFactory("MiningComponents");
    const miningComponents = await MiningComponents.deploy(deployer.address);

    console.log("MiningComponents deployed to:", miningComponents.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
