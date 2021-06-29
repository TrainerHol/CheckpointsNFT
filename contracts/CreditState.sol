// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract CreditState {
    mapping(uint256 => CreditStringProperty) stringProperties;
    uint256 public stringIndex;
    mapping(uint256 => CreditNumberProperty) numberProperties;
    uint256 public intIndex;

    mapping(uint256 => CreditProposal) proposals;
    mapping(uint256 => Credit) createdCredits;

    enum FlowState {
        OPEN,
        ACCEPTED,
        DENIED
    }
    struct Credit {
        mapping(uint256 => string) stringProperties;
        mapping(uint256 => uint256) numberProperties;
    }
    struct CreditProposal {
        FlowState flowState;
        Credit credit;
    }
    struct CreditStringProperty {
        string propertyName;
        bytes1 editable;
    }
    struct CreditNumberProperty {
        string propertyName;
        bytes1 editable;
    }

    function EditCreditString(
        uint256 _creditId,
        uint256 _propertyIndex,
        uint256 _propertyValue
    ) public {
        // TODO: Check that the value is editable
    }

    function AddNumberProperty(string memory _name, bool _editable) public {
        bytes1 editable = _editable ? (bytes1((uint8(1)))) : (bytes1(0));
        numberProperties[intIndex] = CreditNumberProperty(_name, editable);
        intIndex++;
    }

    function AddStringProperty(string memory _name, bool _editable) public {
        bytes1 editable = _editable ? (bytes1((uint8(1)))) : (bytes1(0));
        stringProperties[stringIndex] = CreditStringProperty(_name, editable);
        stringIndex++;
    }
}
