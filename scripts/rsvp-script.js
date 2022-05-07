// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const RSVP = await hre.ethers.getContractFactory("Web3RSVP");
  const [deployer] = await hre.ethers.getSigners();
  const accountBalance = await deployer.getBalance();
  const rsvp = await RSVP.deploy();

  await rsvp.deployed();

  console.log("Deploying contracts with account: ", deployer.address);
  console.log("Web3RSVP deployed to:", rsvp.address);
  console.log("Account balance: ", accountBalance.toString());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

