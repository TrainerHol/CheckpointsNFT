// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract CreditState {
    enum FlowState {
        OPEN,
        ACCEPTED,
        DENIED
    }
    struct Credit {
        mapping(uint256 => CreditStringProperty) stringProperties;
        mapping(uint256 => CreditNumberProperty) numberProperties;
    }
    struct CreditProposal {
        FlowState flowState;
        Credit credit;
    }
    struct CreditStringProperty {
        string propertyName;
        string propertyValue;
        bytes1 editable;
    }
    struct CreditNumberProperty {
        string propertyName;
        uint256 value;
        bytes1 editable;
    }
}
