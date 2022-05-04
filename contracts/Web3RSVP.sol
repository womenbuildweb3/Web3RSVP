// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

//@tod0: add function that "checks people in" to confirm that rsvp'ers actually showed up
//function to payout people who checked in and burn ppl who didn't
//

contract MyToken is ERC721, Pausable, Ownable, ERC721Burnable {
    address payable owner;


    event newEventCreated(uint256 eventID, address creatorAddress, uint eventTimestamp, uint256 maxCapacity, uint256 deposit);

    event newRSVP(uint256 eventID, address attendeeAddress, uint256 rsvpID);

    event confirmedAttendee(
        uint256 eventID,
        address attendeeAddress
        );


    constructor() ERC721("Web3RSVP", "W3RSVP") {
        owner = payable(msg.sender);
    }

    struct CreateEvent {
        uint256 eventId;
        address eventOwner;
        uint256 eventTimestamp;
        uint256 deposit;
        uint256 maxCapacity;
        address[] confirmedRSVPs;
        address[] claimedRSVPs;
        bool paidOut;
    }


    CreateEvent public createevent; 
    mapping(uint256 => CreateEvent ) public idToEvent;

    function createNewEvent(
        uint256 eventTimestamp,
        uint256 deposit,
        uint256 maxCapacity
    ) {
        // generate an eventID based on other things passed in to generate a hash
        bytes32 eventId = keccak256(abi.encodePacked(msg.sender, address(this), eventTimestamp, costPerAttendee, eventName));

        //what does this chunk do exactly?
        //this creates a new CreateEvent struct and adds it to t
       idToEvent[eventId] = CreateEvent(eventId, msg.sender, eventTimestamp, deposit, maxCapacity, [], [], false);

      emit newEventCreated( eventId, msg.sender, eventTimestamp, maxCapacity, deposit);
    }

    function createNewRSVP(uint256 eventId) public payable {
        
        // look up event
        Event myEvent = idToEvent[eventId];

        //require that they sent in enough ETH
        require(msg.value == myEvent.deposit, "NOT ENOUGH");

        //require that the event hasn't already happened (<eventTimestamp)
        require(block.timestamp <= myEvent.eventTimestamp, "ALREADY HAPPENED");

        //you'll need to keep track of how many folks have RSVPED 
        //make sure event is under max capacity
        require(myEvent.confirmedRSVPs.length < myEvent.maxCapacity, "This event has reached capacity"); 

        //require that msg.sender isn't already in myEvent.confirmedRSVPs

        myEvent.confirmedRSVPs.push[msg.sender]; //add user to list of rspvs


        // transfer deposit to our contract 
        // myEvent.deposit
        // use mint functions below
        // transfer ticket cost to event owner
        // myEvent.costPerAttendee ==> myEvent.eventOwner

        // you probably just call _mint here

        emit newRSVP(eventId, msg.sender);
    }

    function confirmGroup(uint256[] eventIds, address[] attendees) public {
        require(eventIds.length == attendees.length, "YUIKES");

        for(uint8 i=0;i<eventIds.length;i++){
            confirmAttendee(eventIds[i], attendees[i]);
        }
    }

    function confirmAttendee(uint256 eventId, address attendee) public {
        // look up event
        Event myEvent = idToEvent[eventId];


        // make sure you require that msg.sender is the owner of the event 

        // transfer deposit from our contract back to attendee
        // myEvent.deposit
        // attendee

        // sending eth back to the staker https://solidity-by-example.org/sending-ether
        (bool sent, bytes memory data) = attendee.call{value: the_amount_they_staked}("");
        require(sent, "Failed to send Ether");
        
        //we need to flip some bool so they can't be confirmed twice 
        // maybe keep a second list of "confirmed" and you check they aren't in that list and then add them 

        // require that attendee is NOT in the claimedRSVPs list

        // add them to the claimedRSVPs list
        myEvent.claimedRSVPs.push(attendee);

        emit newRSVP(eventId, msg.sender);
    }

    function withdrawUnclaimedDeposits(uint256 eventId) public {

        // look up event
        Event myEvent = idToEvent[eventId];

        require(!myEvent.paidOut, "ALREADY PAID");

        myEvent.paidOut = true;

        // check if it's been 7 days past myEvent.eventTimestamp

        // if yes, allow event owner to withdraw unclaimed deposits
        // require msg.sender === myEvent.eventOwner

        // calculate how many people didn't claim by comparing 
        uint8 unclaimed = myEvent.confirmedRSVPs.length - myEvent.claimedRSVPs.length;

        uint256 payout = unclaimed * myEvent.deposit;

        // send the payout to the owner 
        (bool sent, ) = msg.sender.call{value: payout}("");
        require(sent, "Failed to send Ether");

    }

    function setSaleState(bool newState) public onlyOwner {
        _isSaleActive = newState;
    }

    function setBaseURI(string memory URI) external onlyOwner {
        baseURI = URI;
    }    

    function mint(uint8 _numTokens)
        external
        payable
        mintCompliance(_numTokens, MAX_PUBLIC_PURCHASE)
    {
        require(_isSaleActive, 'sale inactive');
        require(msg.value >= (costPerAttendee + deposit) * _numTokens, 'insufficient funds');
        _mintLoop(msg.sender, _numTokens);
    }

    function _mintLoop(address _receiver, uint8 _numTokens) internal {
        for (uint256 i = 0; i < _numTokens; i++) {
            _tokenIdCounter.increment();
            _safeMint(_receiver, _tokenIdCounter.current());
        }
    }

    modifier mintCompliance(uint256 _numTokens, uint256 _maxPurchase) {
        require(
            _numTokens > 0 && _numTokens <= maxCapacity,
            'invalid mint number'
        );
        require(
            _tokenIdCounter.current() + _numTokens <= maxCapacity,
            'not enough spots left'
        );
	
        _;
    }
}
