async function main() {
    // Use the contract addresses provided
    const nftContractAddress = '0x970a8b10147e3459d3cbf56329b76ac18d329728';  // The NFT contract
    const wattTokenAddress = '0xe960d5076cd3169c343ee287a2c3380a222e5839';    // The WATT token contract
    const poolAddress = '0xe66E2A6646F01CE5DF37dC17864645F26021A88e';         // The pool address

    // Get the contract factory
    const MiningRigFactory = await ethers.getContractFactory("MiningRigFactory");

    // Deploy the contract with the addresses
    const rigFactory = await MiningRigFactory.deploy(nftContractAddress, wattTokenAddress, poolAddress);

    await rigFactory.deployed();

    console.log("MiningRigFactory deployed to:", rigFactory.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
