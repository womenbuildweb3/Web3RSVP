const hre = require("hardhat");

const main = async () => {
  const rsvpContractFactory = await hre.ethers.getContractFactory('Web3RSVP');
  const rsvpContract = await rsvpContractFactory.deploy();
  await rsvpContract.deployed();
  console.log("Contract deployed to:", rsvpContract.address);

  const [deployer, address1, address2] = await hre.ethers.getSigners();

  let deposit = hre.ethers.utils.parseEther("1")
  let maxCapacity = 3
  let timestamp = 1652517724
  let eventDataCID = "bafybeihe2gh5zypdiacmz5zl7z3wuhohlepjwysjkbzar5wgaopr4nwqyi"
 
  let txn = await rsvpContract.createNewEvent(timestamp, deposit, maxCapacity, eventDataCID)
  let wait = await txn.wait()
  console.log("NEW EVENT CREATED:", wait.events[0].event, wait.events[0].args)

  let eventID = wait.events[0].args.eventID
  console.log("EVENT ID:", eventID)

  txn = await rsvpContract.createNewRSVP(eventID, {value: deposit})
  wait = await txn.wait()
  console.log("NEW RSVP:", wait.events[0].event, wait.events[0].args)

  txn = await rsvpContract.connect(address1).createNewRSVP(eventID, {value: deposit})
  wait = await txn.wait()
  console.log("NEW RSVP:", wait.events[0].event, wait.events[0].args)

  txn = await rsvpContract.connect(address2).createNewRSVP(eventID, {value: deposit})
  wait = await txn.wait()
  console.log("NEW RSVP:", wait.events[0].event, wait.events[0].args)

  txn = await rsvpContract.confirmAttendee(eventID, deployer.address)
  wait = await txn.wait()

  txn = await rsvpContract.confirmAttendee(eventID, address2.address)
  wait = await txn.wait()

  // wait 10 years
  await hre.network.provider.send("evm_increaseTime", [15778800000000])

  txn = await rsvpContract.withdrawUnclaimedDeposits(eventID)
  wait = await txn.wait()

  // this fails - not authorized
  // txn = await rsvpContract.connect(address1).confirmAttendee(eventID, address1.address)
  // wait = await txn.wait()
  
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

