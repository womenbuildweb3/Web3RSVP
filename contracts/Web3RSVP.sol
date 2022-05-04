// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";



contract MyToken is ERC721, Pausable, Ownable, ERC721Burnable {
    using Counters for Counters.Counter;
    Counters.Counter private _eventIds;
    Counters.Counter private _itemsSold;

    address payable owner;

    constructor() ERC721("Web3RSVP", "W3RSVP") {
        owner = payable(msg.sender);
    }

        event newEventCreated(
            uint256 eventID, 
            address creatorAddress, 
            uint256 timestampCreated, 
            uint256 timestampForEvent, 
            uint256 maxCapacity, 
           uint256  costPerAttendee, 
            uint256 deposit);

    event newRSVP(
        uint256 eventID,
        address attendeeAddress
        );

    event confirmedAttendee(
        uint256 eventID,
        address attendeeAddress
        );

    struct Event {
        uint256 eventId;
        address eventOwner;
        uint256 eventTimestamp;
        uint256 costPerAttendee;
        uint256 deposit;
        string eventName;
        uint256 maxCapacity;
        bool _isSaleActive;
        uint256 maxPerWallet;
        uint256 unclaimedDeposits;
    }

    // private ?
    mapping(uint256 => Event) private idToEvent;

    function createNewEvent(
        uint256 eventId,
        uint256 eventTimestamp,
        uint256 costPerAttendee,
        uint256 deposit,
        string eventName,
        uint256 maxCapacity,
        uint256 maxPerWallet
    ) public {
        idToEvent[eventId] =  Event(
            eventId,
            msg.sender,
            eventTimestamp,
            costPerAttendee,
            deposit,
            eventName,
            maxCapacity,
            false,
            maxPerWallet
        );

      emit newEventCreated(
          eventId, 
          // ?
          msg.sender, 
          // get time now?
          //type now, 
          //block.timestamp ??
          eventTimestamp, 
          maxCapacity, 
          costPerAttendee, 
          deposit
          );
    }

    function createNewRSVP(uint256 eventId) public payable {
        // look up event
        Event myEvent = idToEvent[eventId];

        // transfer deposit to our contract 
        // myEvent.deposit
        // owner
        // msg.sender

        // increment unclaimedDeposits

        // use mint functions below

        // transfer ticket cost to event owner
        // myEvent.costPerAttendee ==> myEvent.eventOwner

        emit newRSVP(eventId, msg.sender);
    }

    function confirmAttendee(uint256 eventId, address attendee) public {
        // look up event
        Event myEvent = idToEvent[eventId];

        // transfer deposit from our contract back to attendee
        // myEvent.deposit
        // attendee

        //decrement unclaimedDepsits

        emit newRSVP(eventId, msg.sender);
    }

    function withdrawUnclaimedDeposits(uint256 eventId) public {
        // look up event
        Event myEvent = idToEvent[eventId];

        // check if it's been 7 days past myEvent.eventTimestamp

        // if yes, allow event owner to withdraw unclaimed deposits
        // require msg.sender === myEvent.eventOwner

        // transfer all unclaimed deposits

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
