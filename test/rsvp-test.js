// const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Create New Event", function () {
  it("should create a new event", async function () {
    const RSVP = await ethers.getContractFactory("Web3RSVP");
    const rsvpContract = await RSVP.deploy();
    await rsvpContract.deployed();

    await rsvpContract.createNewEvent(1652402280, 1, 25);

   await rsvpContract.createNewRSVP('0xab2927d3e22653b508dd3cade3aa71e3e6e53c670b0a342b5f87b422d3e4903e');

  });
});
