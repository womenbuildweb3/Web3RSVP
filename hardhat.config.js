require("@nomiclabs/hardhat-waffle");
require("dotenv").config();
require("hardhat-tracer");

module.exports = {
  solidity: "0.8.4",
  defaultNetwork: "goerli",
  networks: {
    hardhat:{},
    goerli:{
      url: process.env.STAGING_ALCHEMY_KEY,
      accounts: [`0x${process.env.STAGING_PRIVATE_KEY}`],
      gas: 2100000,
      gasPrice: 8000000000,
      saveDeployments: true,
    }
  }
};
