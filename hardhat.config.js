require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("dotenv").config(); // Load environment variables from .env

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.20",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1500,
          },
        },
      },
    ],
  },
  networks: {
    altcoinchain: {
      url: process.env.ALTCOINCHAIN_RPC_URL,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
    fantom: {
      url: process.env.FANTOM_RPC_URL,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
    axelar: {
      url: process.env.AXELAR_RPC_URL,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
    polygon: {
      url: process.env.POLYGON_RPC_URL,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
  },
};
