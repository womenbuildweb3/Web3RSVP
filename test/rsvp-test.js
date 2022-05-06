const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Create New Event", function () {
  it("should create a new event and rsvp", async function () {
    const RSVP = await ethers.getContractFactory("Web3RSVP");
    const rsvpContract = await RSVP.deploy();
    await rsvpContract.deployed();
    let deposit = ethers.utils.parseEther("1")

    await expect(rsvpContract.createNewEvent(1652402280, deposit, 25))
    .to.emit(rsvpContract, "NewEventCreated")
    .withArgs('0xc93edc827ede8716c9cfeac7e6f8b9980572ebf76dd956f408537b302c4068cd', '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266', 1652402280, 25, '1000000000000000000');

    await expect(rsvpContract.createNewRSVP(
      // this is the eventID created above
      '0xc93edc827ede8716c9cfeac7e6f8b9980572ebf76dd956f408537b302c4068cd', 
      {value: deposit}
     ))
     .to.emit(rsvpContract, "NewRSVP")
     .withArgs('0xc93edc827ede8716c9cfeac7e6f8b9980572ebf76dd956f408537b302c4068cd', '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266')

  });
});
