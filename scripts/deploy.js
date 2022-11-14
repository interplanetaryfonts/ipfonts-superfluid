// Simple stream deployment
const hre = require('hardhat');

async function main() {
    const SimpleStream = await hre.ethers.getContractFactory('SimpleStream');
    const simpleStream = await SimpleStream.deploy({ gasLimit: 3000000 });
    await simpleStream.deployed();
    console.log(`SimpleStream deployed to ${simpleStream.address}`);
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});
