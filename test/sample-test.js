const { expect } = require("chai");

describe("CheckpointManager", function() {
  it("Should return the new greeting once it's changed", async function() {
    const CheckpointManager = await hre.ethers.getContractFactory("CheckpointManager");
    const checkpointManager = await CheckpointManager.deploy(0, "0x");
    await checkpointManager.deployed();

    console.log("Checkpoint Manager deployed to:", checkpointManager.address);

    //expect(await greeter.greet()).to.equal("Hello, world!");

    //const setGreetingTx = await greeter.setGreeting("Hola, mundo!");
    
    // wait until the transaction is mined
    //await setGreetingTx.wait();

    //expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
