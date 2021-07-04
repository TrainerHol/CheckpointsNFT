// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract CheckpointState {
    mapping(uint256 => CheckpointStringProperty) stringProperties;
    uint256 public stringIndex;
    mapping(uint256 => CheckpointNumberProperty) numberProperties;
    uint256 public intIndex;

    mapping(uint256 => CheckpointProposal) proposals;
    uint256 propIndex;
    mapping(uint256 => CheckpointFields) createdCheckpoints;
    uint256 createdIndex;

    enum FlowState {
        OPEN,
        ACCEPTED,
        DENIED,
        MINTED
    }
    struct CheckpointFields {
        mapping(uint256 => string) stringProperties;
        mapping(uint256 => uint256) numberProperties;
    }
    struct CheckpointProposal {
        FlowState flowState;
        CheckpointFields checkpoint;
    }
    struct CheckpointStringProperty {
        string propertyName;
        bool editable;
    }
    struct CheckpointNumberProperty {
        string propertyName;
        bool editable;
    }
}
