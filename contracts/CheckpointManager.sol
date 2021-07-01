// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

interface SURF {
    function balanceOf(address) external view returns (uint256);

    function transfer(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);
}

contract CheckpointManager is Ownable {
    using Counters for Counters.Counter;

    SURF surf;
    mapping(uint256 => address) public gameOwners;
    address payable whirlpool;
    uint256 registrationFeeSURF;
    uint256 registrationFee;
    Counters.Counter private _gameIdCounter;

    event GameRegistration(
        address gameOwner,
        string gameName,
        uint256 indexed gameID
    );

    constructor(
        uint256 _registrationFee,
        address payable _whirlpool,
        address _surf
    ) {
        whirlpool = _whirlpool;
        registrationFee = _registrationFee;
        surf = SURF(_surf);
    }

    function RegisterGameWithSURF(string memory game) public {
        uint256 balance = surf.balanceOf(msg.sender);
        require(balance >= registrationFeeSURF, "Not enough SURF");
        bool success = surf.transferFrom(
            msg.sender,
            address(this),
            registrationFeeSURF
        );
        require(success, "SURF Transaction failed");
        gameOwners[_gameIdCounter.current()] = msg.sender;
        emit GameRegistration(msg.sender, game, _gameIdCounter.current());
        _gameIdCounter.increment();
    }

    function CreateCheckpoint(uint256 gameId) public {
        require(
            gameOwners[gameId] == msg.sender,
            "Only the game owner can do this"
        );
        //TODO: Add fields from parameters
    }
}
