const { expect } = require("chai");

describe("Checkpoint", function() {
  let Checkpoint;
  let checkpointContract;
  let owner, address1, address2, address3;

  beforeEach (async function () {
    Checkpoint = await ethers.getContractFactory("Checkpoint");
    [owner, address1, address2, ...address3] = await ethers.getSigners();
    checkpointContract = await Checkpoint.deploy(3, owner, 250, "Name", "SYMBOL");
    await checkpointContract.deployed();
  });

  it("Should set the game owner", async function() {
    console.log("Checkpoint Manager deployed to:", checkpointContract.address);

    expect(await checkpointContract.gameOwner().to.equal(owner));
  });
});
