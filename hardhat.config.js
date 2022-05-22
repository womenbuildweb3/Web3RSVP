require("@nomiclabs/hardhat-waffle");
require("dotenv").config();
require("hardhat-tracer");

module.exports = {
  solidity: "0.8.4",
  networks: {
    hardhat:{
      chainId: 1337
    },
    mumbai: {
      url: process.env.STAGING_INFURA_URL,
      accounts: [`0x${process.env.STAGING_PRIVATE_KEY}`],
      gas: 2100000,
      gasPrice: 8000000000
    }
  }
};
