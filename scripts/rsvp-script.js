// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

const main = async () => {
  const rsvpContractFactory = await hre.ethers.getContractFactory('Web3RSVP');
  const rsvpContract = await rsvpContractFactory.deploy();
  await rsvpContract.deployed();
  console.log("Contract deployed to:", rsvpContract.address);
  
  // const RSVP = await hre.ethers.getContractFactory("Web3RSVP");
  // const [deployer] = await hre.ethers.getSigners();
  // const accountBalance = await deployer.getBalance();
  // const rsvp = await RSVP.deploy();

  // await rsvp.deployed();

  // console.log("Deploying contracts with account: ", deployer.address);
  // console.log("Web3RSVP deployed to:", rsvp.address);
  // console.log("Account balance: ", accountBalance.toString());
 
  let txn = await rsvpContract.createNewEvent(1652402280, 1, 25)
  await txn.wait()
  console.log("TRANSACTION:", txn)
  console.log("created new event")
  
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();

