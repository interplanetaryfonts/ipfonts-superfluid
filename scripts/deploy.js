// Simple stream deployment

const hre = require('hardhat');

async function main() {
    const SimpleStream = await hre.ethers.getContractFactory('SimpleStream');
    const simpleStream = await SimpleStream.deploy({
      host: "0x3E14dC1b13c488a8d5D310918780c983bD5982E7",
      token: "0x96B82B65ACF7072eFEb00502F45757F254c2a0D4",
      thisStreamAmount: 10000,
      thisStreamTime: 10800,
      thisStreamId: "Ligatures"
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
