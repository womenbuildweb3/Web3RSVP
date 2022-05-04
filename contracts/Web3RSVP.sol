// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";



contract MyToken is ERC721, Pausable, Ownable, ERC721Burnable {
    using Counters for Counters.Counter;
    Counters.Counter private _eventIds;
    Counters.Counter private _itemsSold;

    address payable owner;

    event newEventCreated(eventID, creatorAddress, timestampCreated, timestampForEvent, maxCapacity, costPerAttendee, deposit);

    event newRSVP(eventID, attendeeAddress);

    event confirmedAttendee(eventID, attendeeAddress);


    constructor() ERC721("Web3RSVP", "W3RSVP") {
        owner = payable(msg.sender);
    }

    struct Event {
        uint256 eventId,
        address eventOwner,
        uint256 eventTimestamp,
        uint256 public costPerAttendee;
        uint256 public deposit;
        string public eventName;
        uint256 public maxCapacity;
        bool public _isSaleActive;
        uint256 public maxPerWallet;
    }

    // private ?
    mapping(uint256 => Event) private idToEvent;

    function createNewEvent(
        uint256 eventId,
        uint256 eventTimestamp,
        uint256 costPerAttendee,
        uint256 deposit,
        string eventName,
        uint256 maxCapacity;
        uint256 public maxPerWallet
    ) {
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
          now, 
          //block.timestamp ??
          eventTimestamp, 
          maxCapacity, 
          costPerAttendee, 
          deposit
          );
    }

    function newRSVP(eventId) {
        // look up event
        Event myEvent = idToEvent[eventId]

        // check if they have that much in their wallet ????

        // transfer deposit to our contract 
        // myEvent.deposit
        // owner
        // msg.sender

        // use mint functions below

        // transfer ticket cost to event owner
        // myEvent.costPerAttendee ==> myEvent.eventOwner

        emit newRSVP(eventId, msg.sender);
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
