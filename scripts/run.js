const hre = require("hardhat");

const main = async () => {
  const rsvpContractFactory = await hre.ethers.getContractFactory('Web3RSVP');
  const rsvpContract = await rsvpContractFactory.deploy();
  await rsvpContract.deployed();
  console.log("Contract deployed to:", rsvpContract.address);

  const [deployer, address1, address2] = await hre.ethers.getSigners();

  let deposit = hre.ethers.utils.parseEther("1")
  let maxCapacity = 3
  let timestamp = 1718926200
  let eventDataCID = "bafybeibhwfzx6oo5rymsxmkdxpmkfwyvbjrrwcl7cekmbzlupmp5ypkyfi"
 
  let txn = await rsvpContract.createNewEvent(timestamp, deposit, maxCapacity, eventDataCID)
  let wait = await txn.wait()
  console.log("NEW EVENT CREATED:", wait.events[0].event, wait.events[0].args)

  let eventId = wait.events[0].args.eventId
  console.log("EVENT ID:", eventId)

  txn = await rsvpContract.createNewRSVP(eventId, {value: deposit})
  wait = await txn.wait()
  console.log("NEW RSVP:", wait.events[0].event, wait.events[0].args)

  txn = await rsvpContract.connect(address1).createNewRSVP(eventId, {value: deposit})
  wait = await txn.wait()
  console.log("NEW RSVP:", wait.events[0].event, wait.events[0].args)

  txn = await rsvpContract.connect(address2).createNewRSVP(eventId, {value: deposit})
  wait = await txn.wait()
  console.log("NEW RSVP:", wait.events[0].event, wait.events[0].args)

  txn = await rsvpContract.confirmAllAttendees(eventId)
  wait = await txn.wait()
  wait.events.forEach(event => console.log("CONFIRMED:", event.args.attendeeAddress))

  // wait 10 years
  await hre.network.provider.send("evm_increaseTime", [15778800000000])

  txn = await rsvpContract.withdrawUnclaimedDeposits(eventId)
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

