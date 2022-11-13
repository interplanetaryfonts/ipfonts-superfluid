const {
    time,
    loadFixture,
} = require('@nomicfoundation/hardhat-network-helpers');
const { expect } = require('chai');

describe('SimpleStream', function () {
    async function deploySimpleStream() {
        // Deployment values
        const host = '0x3E14dC1b13c488a8d5D310918780c983bD5982E7',
            token = '0x96B82B65ACF7072eFEb00502F45757F254c2a0D4',
            thisStreamAmount = 10000,
            thisStreamTime = 10800,
            thisStreamId = 'Ligatures';
        const SimpleStream = await ethers.getContractFactory('SimpleStream');
        const simpleStream = await SimpleStream.deploy({
            host,
            token,
            thisStreamAmount,
            thisStreamTime,
            thisStreamId,
        });

        return {
            simpleStream,
            host,
            token,
            thisStreamAmount,
            thisStreamTime,
            thisStreamId,
        };
    }

    describe('Deployment', function () {
        it('Should initialize the contract correctly', async function () {
            const {
                simpleStream,
                host,
                token,
                thisStreamAmount,
                thisStreamTime,
                thisStreamId,
            } = await loadFixture(deploySimpleStream);

            expect(await simpleStream.host).to.equal(host);
            expect(await simpleStream.token).to.equal(token);
            expect(await simpleStream.thisStreamAmount).to.equal(
                thisStreamAmount
            );
            expect(await simpleStream.thisStreamTime).to.equal(thisStreamTime);
            expect(await simpleStream.host).to.equal(host);
            expect(await simpleStream.thisStreamId).to.equal(thisStreamId);
        });
    });
});
