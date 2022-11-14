//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// Superfluid imports
import {ISuperfluid, ISuperToken} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
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
        uint256 fund;
    }
    //  Stream structure (change to struct in more complex streams)
    bool public open;
    bool public finished;
    string public streamId;
    uint256 public streamAmount;
    uint256 public streamTime;
    ISuperToken streamToken;
    uint256 public numOwners;
    mapping(uint256 => address) public owners;
    uint256 public numFunders;
    mapping(uint256 => Funder) public funders;
    // Fund event
    event Funded(
        string Identifier,
        address indexed NewFunder,
        uint256 indexed Amount,
        ISuperToken Token
    );

    // Build constructor
    constructor() payable {
        // Initialize CFA Library
        ISuperfluid host = ISuperfluid(
            0xEB796bdb90fFA0f28255275e16936D25d3418603
        );
        cfaV1 = CFAv1Library.InitData(
            host,
            IConstantFlowAgreementV1(
                address(
                    host.getAgreementClass(
                        keccak256(
                            "org.superfluid-finance.agreements.ConstantFlowAgreement.v1"
                        )
                    )
                )
            )
        );
    }

    // After the stream is created the
    function setStream(
        uint256 newStreamAmount,
        uint256 newStreamTime,
        string memory newStreamId
    ) external {
        require(!open && !finished, "Stream already set");
        // Initialize stream state
        open = true;
        numOwners++;
        owners[numOwners] = payable(msg.sender);
        streamToken = ISuperToken(0x96B82B65ACF7072eFEb00502F45757F254c2a0D4);
        streamAmount = newStreamAmount;
        streamTime = newStreamTime;
        streamId = newStreamId;
    }

    //Simple stream starts here
    function fundStream(address payable newFunder, uint256 amount)
        public
        payable
    {
        // Check if the stream can still receive funds
        require(open && !finished, "This stream is closed!");
        require(
            address(this).balance + amount <= streamAmount,
            "You can't exceed this stream amount!"
        );
        // Check for the stream to be completed
        if (address(this).balance == streamAmount) {
            open = false;
            finished = true;
        }
        // Update funders list
        numFunders++;
        funders[numFunders] = Funder(newFunder, amount);
        // Emit an event for this update
        emit Funded(streamId, newFunder, amount, streamToken);
        // Get the share to stream between all of the owners of the stream
        uint256 share = amount / numOwners;
        // Initialize the CFA among all of the owners of the stream
        for (uint256 owner = 1; owner <= numOwners; owner++) {
            cfaV1.createFlow(
                owners[owner],
                streamToken,
                int96(uint96(share / streamTime))
            );
        }
    }
}
