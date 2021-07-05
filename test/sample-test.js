const { expect } = require("chai");

describe("CheckpointManager", function() {
  let CheckpointManager;
  let checkpointManagerContract;
  let owner, address1, address2, address3;

  beforeEach (async function () {
    CheckpointManager = await ethers.getContractFactory("CheckpointManager");
    [owner, address1, address2, ...address3] = await ethers.getSigners();
    checkpointManagerContract = await CheckpointManager.deploy(0, 0x0);
    await checkpointManagerContract.deployed();
  });

  it("Should deploy the contract", async function() {
    console.log("Checkpoint Manager deployed to:", checkpointManagerContract.address);

    expect(await checkpointManagerContract.minimumSURF().to.equal(0));
  });
});
