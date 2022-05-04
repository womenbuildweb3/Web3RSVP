// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

// to do: figure out how to push to confirmedRSVPs / claimedRSVPs 

contract MyToken is ERC721, Pausable, Ownable, ERC721Burnable {
    address payable owner;

    event newEventCreated(
        bytes32 eventID,
        address creatorAddress,
        uint256 eventTimestamp,
        uint256 maxCapacity,
        uint256 deposit
    );

    event newRSVP(bytes32 eventID, address attendeeAddress);

    event confirmedAttendee(bytes32 eventID, address attendeeAddress);

    constructor() ERC721("Web3RSVP", "W3RSVP") {
        owner = payable(msg.sender);
    }

    struct CreateEvent {
        bytes32 eventId;
        address eventOwner;
        uint256 eventTimestamp;
        uint256 deposit;
        uint256 maxCapacity;
        address[] confirmedRSVPs;
        address[] claimedRSVPs;
        bool paidOut;
    }

    CreateEvent public createevent;
    mapping(bytes32 => CreateEvent) public idToEvent;

    function createNewEvent(
        uint256 eventTimestamp,
        uint256 deposit,
        uint256 maxCapacity
    ) public {
        // generate an eventID based on other things passed in to generate a hash
        bytes32 eventId = keccak256(
            abi.encodePacked(
                msg.sender,
                address(this),
                eventTimestamp,
                deposit,
                maxCapacity
            )
        );

        address[] memory confirmedRSVPs;
        address[] memory claimedRSVPs;

        //this creates a new CreateEvent struct and adds it to the idToEvent mapping
        idToEvent[eventId] = CreateEvent(
            eventId,
            msg.sender,
            eventTimestamp,
            deposit,
            maxCapacity,
            confirmedRSVPs,
            claimedRSVPs,
            false
        );

        emit newEventCreated(
            eventId,
            msg.sender,
            eventTimestamp,
            maxCapacity,
            deposit
        );
    }

    function createNewRSVP(bytes32 eventId) public payable {
        // look up event
        CreateEvent memory myEvent = idToEvent[eventId];

        // transfer deposit to our contract / require that they sent in enough ETH
        require(msg.value == myEvent.deposit, "NOT ENOUGH");

        //require that the event hasn't already happened (<eventTimestamp)
        require(block.timestamp <= myEvent.eventTimestamp, "ALREADY HAPPENED");

        //make sure event is under max capacity
        require(
            myEvent.confirmedRSVPs.length < myEvent.maxCapacity,
            "This event has reached capacity"
        );

        //require that msg.sender isn't already in myEvent.confirmedRSVPs
        // is there an array.contains() method?
        for (uint8 i = 0; i < myEvent.confirmedRSVPs.length; i++) {
            require(myEvent.confirmedRSVPs[i] != msg.sender);
        }

        //we'll need to keep track of how many folks have RSVPED
        // this won't work ? because myEvent is stored in memory ?
        myEvent.confirmedRSVPs.push[msg.sender]; //add user to list of rspvs

        emit newRSVP(eventId, msg.sender);
    }

    function confirmGroup(bytes32 eventId, address[] calldata attendees) public {
        // look up event
        CreateEvent memory myEvent = idToEvent[eventId];

        // make sure you require that msg.sender is the owner of the event
        require(msg.sender == myEvent.eventOwner);

        //confirm each attendee
        for (uint8 i = 0; i < attendees.length; i++) {
            confirmAttendee(eventId, attendees[i]);
        }
    }

    function confirmAttendee(bytes32 eventId, address attendee) public {
        // look up event
        CreateEvent memory myEvent = idToEvent[eventId];

        // make sure you require that msg.sender is the owner of the event
        require(msg.sender == myEvent.eventOwner);

        // require that attendee is in myEvent.confirmedRSVPs
        // ?

        // require that attendee is NOT in the claimedRSVPs list
        // is there an array.contains() method?
        for (uint8 i = 0; i < myEvent.claimedRSVPs.length; i++) {
            require(myEvent.claimedRSVPs[i] != msg.sender);
        }

        // add them to the claimedRSVPs list
        // this wont work ?
        myEvent.claimedRSVPs.push(attendee);

        // sending eth back to the staker https://solidity-by-example.org/sending-ether
        (bool sent, bytes memory data) = attendee.call{value: myEvent.deposit}(
            ""
        );
        require(sent, "Failed to send Ether");
        //what happens if this fails?

        emit newRSVP(eventId, msg.sender);
    }

    function withdrawUnclaimedDeposits(bytes32 eventId) public {
        // look up event
        CreateEvent memory myEvent = idToEvent[eventId];

        // check if already paid
        require(!myEvent.paidOut, "ALREADY PAID");

        // check if it's been 7 days past myEvent.eventTimestamp
        require(
            block.timestamp >= (myEvent.eventTimestamp + 7 days),
            "TOO EARLY"
        );

        // only the event owner can withdraw
        require(msg.sender == myEvent.eventOwner, "MUST BE EVENT OWNER");

        // mark as paid
        myEvent.paidOut = true;

        // calculate how many people didn't claim by comparing
        uint256 unclaimed = myEvent.confirmedRSVPs.length -
            myEvent.claimedRSVPs.length;

        uint256 payout = unclaimed * myEvent.deposit;

        // send the payout to the owner
        (bool sent, ) = msg.sender.call{value: payout}("");
        require(sent, "Failed to send Ether");
        // what happens if this fails?
    }
}
