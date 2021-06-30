// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./CreditState.sol";

interface SURF {
    function balanceOf(address) external view returns (uint256);

    function transfer(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);
}

contract GameDevCredits is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    AccessControl,
    Credit
{
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("GAME_DEV");
    uint256 maxSupply;
    Counters.Counter private _tokenIdCounter;

    constructor(uint256 _maxSupply) ERC721("Checkpoints", "CHECKPOINTS") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        maxSupply = _maxSupply;
    }

    function safeMint(address to, uint256 proposalId) public {
        require(hasRole(MINTER_ROLE, msg.sender));
        require(
            proposals[proposalId].flowState == FlowState.ACCEPTED,
            "Proposal has not been accepted"
        );
        require(_tokenIdCounter.current() < maxSupply, "Max supply reached");
        _safeMint(to, _tokenIdCounter.current());
        CreditFields storage credits = createdCredits[
            _tokenIdCounter.current()
        ];
        credits = proposals[proposalId].credit;
        _tokenIdCounter.increment();
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
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    modifier onlyTokenOwner(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender, "");
        _;
    }

    function CreateCredit(
        uint256[] memory numberValues,
        string[] memory stringValues
    ) public onlyOwner {}

    function EditCreditString(
        uint256 _creditId,
        uint256 _propertyIndex,
        string memory _propertyValue
    ) public onlyTokenOwner(_creditId) {
        require(
            stringProperties[_propertyIndex].editable,
            "Property not editable"
        );
        createdCredits[_creditId].stringProperties[
            _propertyIndex
        ] = _propertyValue;
    }

    function EditCreditNumber(
        uint256 _creditId,
        uint256 _propertyIndex,
        uint256 _propertyValue
    ) public onlyTokenOwner(_creditId) {
        require(
            numberProperties[_propertyIndex].editable,
            "Property not editable"
        );
        createdCredits[_creditId].numberProperties[
            _propertyIndex
        ] = _propertyValue;
    }

    function AddNumberProperty(string memory _name, bool _editable)
        public
        onlyOwner
    {
        numberProperties[intIndex] = CreditNumberProperty(_name, _editable);
        intIndex++;
    }

    function AddStringProperty(string memory _name, bool _editable)
        public
        onlyOwner
    {
        stringProperties[stringIndex] = CreditStringProperty(_name, _editable);
        stringIndex++;
    }
}
