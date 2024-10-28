async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
  
    const balance = await deployer.getBalance();
    console.log("Account balance:", ethers.utils.formatEther(balance));
  
    // Deploy MiningRigFactory contract
    const MiningRigFactory = await ethers.getContractFactory("MiningRigFactory");
    const factory = await MiningRigFactory.deploy();
  
    console.log("MiningRigFactory deployed to address:", factory.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  