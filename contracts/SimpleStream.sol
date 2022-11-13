//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// Superfluid imports
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ISuperfluid, ISuperToken, ISuperApp} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import {ISuperfluidToken} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluidToken.sol";
import {IConstantFlowAgreementV1} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";
import {CFAv1Library} from "@superfluid-finance/ethereum-contracts/contracts/apps/CFAv1Library.sol";

contract SimpleStream {
    // Superfluid
    using CFAv1Library for CFAv1Library.InitData;
    CFAv1Library.InitData public cfaV1;

    //  Funder structure
    struct Funder {
        address funderAddress;
        uint fund;
    }

    //  Stream structure (change to struct in more complex streams)
    uint public numOwners;
    mapping(uint => address) public owners;
    uint public streamAmount;
    ISuperToken streamToken;
    uint public streamTime;
    string public streamId;
    bool public open = true;
    uint public numFunders;
    mapping(uint => Funder) public funders;

    // Fund events
    event Funded(
        string Identifier,
        address NewFunder,
        uint Amount,
        ISuperToken Token
    );

    // Build constructor
    constructor(
        ISuperfluid host,
        ISuperToken token,
        uint thisStreamAmount,
        uint thisStreamTime,
        string memory thisStreamId
    ) {
        // Initialize CFA Library
        cfaV1 = CFAv1Library.InitData(
            host,
            IConstantFlowAgreementV1(
                address(
                    host.getAgreementClass(
                        keccak256("org.superfluid-finance.agreements.ConstantFlowAgreement.v1")
                    )
                )
            )
        );
        // Initialize stream state
        numOwners = 1;
        owners[numOwners] = msg.sender;
        streamAmount = thisStreamAmount;
        streamTime = thisStreamTime;
        streamId = thisStreamId;
        streamToken = token;
    }
    
    //Simple stream starts here
    function fundStream(address newFunder, uint amount) public payable {
        // Check if the stream can still receive funds
        require(open, "This stream is closed!");
        require(address(this).balance + amount <= streamAmount, "You can't exceed this stream amount!");
        // Check for the stream to be completed
        if (address(this).balance == streamAmount) {
            open = false;
        }
        // Update funders list
        numFunders++;
        funders[numFunders] = Funder(newFunder, amount);
        // Emit an event for this update
        emit Funded(streamId, newFunder, amount, streamToken);
        // Get the share to stream between all of the owners of the stream
        uint share = amount / numOwners;
        // Initialize the CFA among all of the owners of the stream
        for (uint owner = 1; owner <= numOwners; owner++) {
            cfaV1.createFlow(owners[owner], streamToken, int96(uint96(share / streamTime)));
        }
    }
}
