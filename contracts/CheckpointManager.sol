// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Checkpoint.sol";

interface SURF {
    function balanceOf(address) external view returns (uint256);

    function transfer(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);
}

contract CheckpointManager {
    using Counters for Counters.Counter;

    SURF surf;
    mapping(uint256 => address) public gameOwners;
    mapping(uint256 => Checkpoint[]) public gameCheckpoints;
    mapping(uint256 => string) public gameNames;
    uint256 minimumSURF;
    Counters.Counter private _gameIdCounter;

    event GameRegistration(
        address indexed gameOwner,
        string gameName,
        uint256 indexed gameID
    );
    event CheckpointCreation(
        uint256 indexed gameID,
        address indexed checkpointAddress,
        string name,
        uint256 maxSupply
    );

    constructor(uint256 _minimumSURF, address _surf) {
        minimumSURF = _minimumSURF;
        surf = SURF(_surf);
    }

    //Registers a game for free only if the address holds at least x amount of SURF
    function RegisterGameWithSURF(string memory game) public {
        uint256 balance = surf.balanceOf(msg.sender);
        require(balance >= minimumSURF, "Not enough SURF");
        uint256 index = _gameIdCounter.current();
        gameOwners[index] = msg.sender;
        gameNames[index] = game;
        emit GameRegistration(msg.sender, game, index);
        _gameIdCounter.increment();
    }

    function CreateCheckpoint(
        uint256 gameId,
        uint256 maxSupply,
        uint256 mintingPrice,
        string memory _name,
        string memory _symbol
    ) public onlyGameOwner(gameId) {
        gameCheckpoints[gameId].push(
            new Checkpoint(maxSupply, msg.sender, mintingPrice, _name, _symbol)
        );
        uint256 lastIndex = gameCheckpoints[gameId].length - 1;
        emit CheckpointCreation(
            gameId,
            address(gameCheckpoints[gameId][lastIndex]),
            _name,
            maxSupply
        );
    }

    modifier onlyGameOwner(uint256 gameId) {
        require(gameOwners[gameId] == msg.sender, "Only game owner");
        _;
    }
}
