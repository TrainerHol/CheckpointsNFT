// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";

contract Credit is Ownable {
    mapping(uint256 => CreditStringProperty) stringProperties;
    uint256 public stringIndex;
    mapping(uint256 => CreditNumberProperty) numberProperties;
    uint256 public intIndex;

    mapping(uint256 => CreditProposal) proposals;
    mapping(uint256 => CreditFields) createdCredits;

    enum FlowState {
        OPEN,
        ACCEPTED,
        DENIED
    }
    struct CreditFields {
        mapping(uint256 => string) stringProperties;
        mapping(uint256 => uint256) numberProperties;
    }
    struct CreditProposal {
        FlowState flowState;
        CreditFields credit;
    }
    struct CreditStringProperty {
        string propertyName;
        bool editable;
    }
    struct CreditNumberProperty {
        string propertyName;
        bool editable;
    }
}
