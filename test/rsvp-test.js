const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Create New Event", function () {
  it("should create a new event, rsvp, and confirm", async function () {
    const RSVP = await ethers.getContractFactory("Web3RSVP");
    const rsvpContract = await RSVP.deploy();
    await rsvpContract.deployed();

    const [deployer, address1, address2] = await hre.ethers.getSigners();

    let deposit = hre.ethers.utils.parseEther("1")
    let maxCapacity = 3
    let timestamp = 1718926200
    let eventDataCID = "bafybeibhwfzx6oo5rymsxmkdxpmkfwyvbjrrwcl7cekmbzlupmp5ypkyfi"

    let address = deployer.adress
    let eventID = "0x8a054be2ea682cd0bdd68f85c9e0aa6d8ac442d7b2716f0a1baab0954490af68"


    await expect(rsvpContract.createNewEvent(timestamp, deposit, maxCapacity, eventDataCID))
    .to.emit(rsvpContract, "NewEventCreated")

    await expect(rsvpContract.createNewRSVP(
      eventID,
      {value: deposit}
     ))
     .to.emit(rsvpContract, "NewRSVP")
     
    await expect(rsvpContract.connect(address1).createNewRSVP(
      eventID,
      {value: deposit}
     ))
     .to.emit(rsvpContract, "NewRSVP")

     await rsvpContract.confirmAllAttendees(eventID)

     
  });
});