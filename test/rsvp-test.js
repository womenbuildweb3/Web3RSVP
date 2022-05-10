const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Create New Event", function () {
  it("should create a new event, rsvp, and confirm", async function () {
    const RSVP = await ethers.getContractFactory("Web3RSVP");
    const rsvpContract = await RSVP.deploy();
    await rsvpContract.deployed();
    let deposit = ethers.utils.parseEther("1")

    let eventID = '0xf6a3554d595aaa4bde8c3bd8e4be175cbc49ce77fa8f1e3e6bcf77787bdaaced'

    await expect(rsvpContract.createNewEvent(1683769877, deposit, 25, "my party"))
    .to.emit(rsvpContract, "NewEventCreated")
    .withArgs(eventID, '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266', 1683769877, 25, '1000000000000000000', "my party");

    await expect(rsvpContract.createNewRSVP(
      // this is the eventID created above
      eventID,
      {value: deposit}
     ))
     .to.emit(rsvpContract, "NewRSVP")
     .withArgs(eventID, '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');

     await expect(rsvpContract.confirmAttendee(
      // this is the eventID created above
      eventID,
      '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266'
     ))
     .to.emit(rsvpContract, "ConfirmedAttendee")
     .withArgs(eventID, '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266');
  });
});