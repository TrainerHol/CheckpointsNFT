// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./CheckpointState.sol";

contract Checkpoint is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    AccessControl,
    CheckpointState
{
    using Counters for Counters.Counter;

    bytes32 public constant GAME_DEV = keccak256("GAME_DEV");
    uint256 public maxSupply;
    uint256 public mintingPrice;
    Counters.Counter private _tokenIdCounter;
    bool public isLocked;
    address payable public gameOwner;
    string public contractURI;

    event proposalCreation(address indexed creator, uint256 indexed proposalId);
    event proposalApproval(uint256 indexed proposalId);
    event proposalDenial(uint256 indexed proposalId);
    event proposalMinted(uint256 indexed proposalId, uint256 payment);

    constructor(
        uint256 _maxSupply,
        address _gameOwner,
        uint256 _mintingPrice,
        string memory _checkpointName,
        string memory _checkpointSymbol
    ) ERC721(_checkpointName, _checkpointSymbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(GAME_DEV, msg.sender);
        gameOwner = payable(_gameOwner);
        mintingPrice = _mintingPrice;
        _setupRole(GAME_DEV, gameOwner);
        maxSupply = _maxSupply;
    }

    function AcceptProposal(uint256 proposalId) public onlyGameDev {
        require(proposals[proposalId].flowState == FlowState.OPEN);
        proposals[proposalId].flowState = FlowState.ACCEPTED;
        emit proposalApproval(proposalId);
    }

    function DenyProposal(uint256 proposalId) public onlyGameDev {
        require(proposals[proposalId].flowState == FlowState.OPEN);
        proposals[proposalId].flowState = FlowState.DENIED;
        emit proposalDenial(proposalId);
    }

    function safeMint(address to, uint256 proposalId) public payable {
        require(msg.value >= mintingPrice, "Minting price not met");
        require(
            proposals[proposalId].flowState == FlowState.ACCEPTED,
            "Proposal has not been accepted"
        );
        require(_tokenIdCounter.current() < maxSupply, "Max supply reached");
        _safeMint(to, _tokenIdCounter.current());
        CheckpointFields storage checkpoints = createdCheckpoints[
            _tokenIdCounter.current()
        ];
        for (uint256 index = 0; index < intIndex; index++) {
            checkpoints.numberProperties[index] = proposals[proposalId]
            .checkpoint
            .numberProperties[index];
        }
        for (uint256 index = 0; index < stringIndex; index++) {
            checkpoints.stringProperties[index] = getStringValue(
                proposalId,
                index
            );
        }
        proposals[proposalId].flowState = FlowState.MINTED;
        _tokenIdCounter.increment();
        emit proposalMinted(proposalId, msg.value);
    }

    function WithdrawPayments() public onlyGameDev {
        require(address(this).balance > 0, "Nothing to withdraw");
        gameOwner.transfer(address(this).balance);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        string memory metadata = "{\n";
        CheckpointFields storage fields = createdCheckpoints[tokenId];
        // Loop through string fields
        for (uint256 index = 0; index < stringIndex; index++) {
            metadata = string(abi.encodePacked(metadata, '"'));
            metadata = string(
                abi.encodePacked(metadata, stringProperties[index].propertyName)
            );
            metadata = string(abi.encodePacked(metadata, '": '));
            metadata = string(abi.encodePacked(metadata, '"'));
            metadata = string(
                abi.encodePacked(
                    metadata,
                    string(fields.stringProperties[index])
                )
            );
            metadata = string(abi.encodePacked(metadata, '"'));
            if (index != stringIndex - 1) {
                metadata = string(abi.encodePacked(metadata, ",\n"));
            }
        }
        if (stringIndex > 0 && intIndex > 0) {
            metadata = string(abi.encodePacked(metadata, ",\n"));
        }
        // Loop through numerical fields
        for (uint256 index = 0; index < intIndex; index++) {
            metadata = string(abi.encodePacked(metadata, '"'));
            metadata = string(
                abi.encodePacked(metadata, numberProperties[index].propertyName)
            );
            metadata = string(abi.encodePacked(metadata, '": '));
            metadata = string(abi.encodePacked(metadata, '"'));
            metadata = string(
                abi.encodePacked(
                    metadata,
                    uint2str(fields.numberProperties[index])
                )
            );
            metadata = string(abi.encodePacked(metadata, '"'));
            if (index != intIndex - 1) {
                metadata = string(abi.encodePacked(metadata, ",\n"));
            }
        }
        metadata = string(abi.encodePacked(metadata, "\n}"));
        return metadata;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function LockStructure() public onlyGameDev {
        require(!isLocked, "Already locked");
        isLocked = true;
    }

    function CreateProposal(
        uint256[] memory numberValues,
        string[] memory stringValues
    ) public onlyWhenLocked {
        require(
            numberValues.length == intIndex &&
                stringValues.length == stringIndex,
            "Incorrect structure"
        );
        CheckpointProposal storage prop = proposals[propIndex];
        prop.flowState = FlowState.OPEN;
        mapping(uint256 => uint256) storage numProperties = prop
        .checkpoint
        .numberProperties;
        for (uint256 index = 0; index < numberValues.length; index++) {
            numProperties[index] = numberValues[index];
        }
        mapping(uint256 => string) storage strProperties = prop
        .checkpoint
        .stringProperties;
        for (uint256 index = 0; index < stringValues.length; index++) {
            strProperties[index] = stringValues[index];
        }
        emit proposalCreation(msg.sender, propIndex);
        propIndex++;
    }

    function EditCheckpointString(
        uint256 _checkpointId,
        uint256 _propertyIndex,
        string memory _propertyValue
    ) public onlyTokenOwner(_checkpointId) {
        require(
            stringProperties[_propertyIndex].editable,
            "Property not editable"
        );
        createdCheckpoints[_checkpointId].stringProperties[
            _propertyIndex
        ] = _propertyValue;
    }

    function EditCheckpointNumber(
        uint256 _checkpointId,
        uint256 _propertyIndex,
        uint256 _propertyValue
    ) public onlyTokenOwner(_checkpointId) {
        require(
            numberProperties[_propertyIndex].editable,
            "Property not editable"
        );
        createdCheckpoints[_checkpointId].numberProperties[
            _propertyIndex
        ] = _propertyValue;
    }

    function AddNumberProperty(string memory _name, bool _editable)
        public
        onlyGameDev
        onlyWhenUnlocked
    {
        numberProperties[intIndex] = CheckpointNumberProperty(_name, _editable);
        intIndex++;
    }

    function AddStringProperty(string memory _name, bool _editable)
        public
        onlyGameDev
        onlyWhenUnlocked
    {
        stringProperties[stringIndex] = CheckpointStringProperty(
            _name,
            _editable
        );
        stringIndex++;
    }

    modifier onlyTokenOwner(uint256 _tokenId) {
        require(
            ownerOf(_tokenId) == msg.sender,
            "Only the token owner can do this"
        );
        _;
    }

    modifier onlyGameDev() {
        require(hasRole(GAME_DEV, msg.sender), "Game dev role required");
        _;
    }

    modifier onlyWhenUnlocked() {
        require(!isLocked, "Structure is locked");
        _;
    }

    modifier onlyWhenLocked() {
        require(isLocked, "Structure must be locked first");
        _;
    }

    //For OpenSea Listing
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool isOperator)
    {
        if (_operator == address(0x58807baD0B376efc12F5AD86aAc70E78ed67deaE)) {
            return true;
        }

        return ERC721.isApprovedForAll(_owner, _operator);
    }

    function setContractURI(string memory _contractURI) public onlyGameDev {
        contractURI = _contractURI;
    }

    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
