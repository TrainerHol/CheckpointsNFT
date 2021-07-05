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

    function getProposalData(uint256 proposalId)
        public
        view
        returns (
            FlowState state,
            string[] memory strings,
            uint256[] memory integers
        )
    {
        CheckpointProposal storage prop = proposals[proposalId];
        state = prop.flowState;
        for (uint256 index = 0; index < stringIndex; index++) {
            strings[index] = prop.checkpoint.stringProperties[index];
        }
        for (uint256 index = 0; index < stringIndex; index++) {
            integers[index] = prop.checkpoint.numberProperties[index];
        }
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
