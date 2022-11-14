import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';

describe('SimpleStream', function () {
    async function deploySimpleStream() {
        // Deployment values
        const SimpleStream = await ethers.getContractFactory('SimpleStream');
        const simpleStream = await SimpleStream.deploy();

        return {
            simpleStream,
        };
    }

    describe('Deployment', function () {
        it('Should initialize the contract correctly', async function () {
            const { simpleStream } = await loadFixture(deploySimpleStream);
            expect(await simpleStream.numOwners).to.equal(1);
        });
    });
});
