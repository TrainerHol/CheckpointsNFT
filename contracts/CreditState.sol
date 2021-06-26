// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract CreditState {
    enum FlowState {OPEN, ACCEPTED, DENIED}
    struct Credit {
        mapping (uint => CreditStringProperty) stringProperties;
        mapping (uint => CreditNumberProperty) numberProperties;
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
        uint value;
        bytes1 editable;
    }

}