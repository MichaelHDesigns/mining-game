// scripts/deploy_MiningRigDeployer.js
async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const MiningRigDeployer = await ethers.getContractFactory("MiningRigDeployer");

    // Replace `nftContractAddress` with the actual deployed address of your NFT contract.
    const nftContractAddress = "0x970A8b10147E3459D3CBF56329B76aC18D329728"; // e.g., MiningComponents address
    const initialOwner = deployer.address;

    const miningRigDeployer = await MiningRigDeployer.deploy(nftContractAddress, initialOwner);
    await miningRigDeployer.deployed();

    console.log("MiningRigDeployer deployed to:", miningRigDeployer.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
