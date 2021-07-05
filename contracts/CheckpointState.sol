// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract CheckpointState {
    mapping(uint256 => CheckpointStringProperty) public stringProperties;
    uint256 public stringIndex;
    mapping(uint256 => CheckpointNumberProperty) public numberProperties;
    uint256 public intIndex;

    mapping(uint256 => CheckpointProposal) proposals;
    uint256 public propIndex;
    mapping(uint256 => CheckpointFields) createdCheckpoints;

    enum FlowState {
        OPEN,
        ACCEPTED,
        DENIED,
        MINTED
    }

    function getStringValue(uint256 _propId, uint256 _strIndex)
        public
        view
        returns (string memory)
    {
        return proposals[_propId].checkpoint.stringProperties[_strIndex];
    }

    function getNumericalValue(uint256 _propId, uint256 _index)
        public
        view
        returns (uint256)
    {
        return proposals[_propId].checkpoint.numberProperties[_index];
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
