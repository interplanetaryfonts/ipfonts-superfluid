// Simple stream deployment

const hre = require('hardhat');

async function main() {
    const interface = new hre.ethers.interface([])
    const SimpleStream = await hre.ethers.getContractFactory('SimpleStream');
    const simpleStream = await SimpleStream.deploy(interface, {
        value: lockedAmount,
    });
    await simpleStream.deployed();

    console.log(`SimpleStream deployed to ${simpleStream.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});
