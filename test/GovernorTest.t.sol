// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {Test,console} from 'forge-std/Test.sol';
import {Box} from '../src/Box.sol';
import {GovToken} from '../src/GovToken.sol';
import {MyGovernor} from '../src/MyGovernor.sol';
import {TimeLock} from '../src/TimeLock.sol';

contract GovernorTest is Test{
 
 Box box;
 GovToken govToken;
 MyGovernor governor;
 TimeLock timeLock;

 address public USER=makeAddr('user');
 uint256 public constant INITIAL_SUPPLY=1000e18;
 uint256 public constant VOTING_DELAY=7200 seconds; // 2 hours

 address[] public proposers;
    address[] public executors;

 function setUp() public {
    //  box = new Box();
     govToken = new GovToken();
    govToken.mint(USER, INITIAL_SUPPLY);


    vm.startPrank(USER);
    govToken.delegate(USER);

     timeLock = new TimeLock(VOTING_DELAY, proposers, executors);

     governor = new MyGovernor(govToken, timeLock);

     bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.TIMELOCK_ADMIN_ROLE();

        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        timelock.revokeRole(adminRole, msg.sender);
        vm.stopPrank();
        // Transfer ownership of the box to the timelock

        box = new Box();
        box.transferOwnership(address(timeLock));

   }

       function testCantUpdateBoxWithoutGovernance() public {
        vm.expectRevert();
        box.store(1);
    }


        function testGovernanceUpdatesBox() public {
        uint256 valueToStore = 777;
        string memory description = "Store 1 in Box";
        bytes memory encodedFunctionCall = abi.encodeWithSignature("store(uint256)", valueToStore);
        addressesToCall.push(address(box));
        values.push(0);
        functionCalls.push(encodedFunctionCall);
        // 1. Propose to the DAO
        uint256 proposalId = governor.propose(addressesToCall, values, functionCalls, description);

        console.log("Proposal State:", uint256(governor.state(proposalId)));
      

        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        console.log("Proposal State:", uint256(governor.state(proposalId)));

        // 2. Vote
        string memory reason = "I like a do da cha cha";
        // 0 = Against, 1 = For, 2 = Abstain for this example

        uint8 voteWay = 1;
        vm.prank(VOTER);
        governor.castVoteWithReason(proposalId, voteWay, reason);

        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        console.log("Proposal State:", uint256(governor.state(proposalId)));

        // 3. Queue
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governor.queue(addressesToCall, values, functionCalls, descriptionHash);
        vm.roll(block.number + MIN_DELAY + 1);
        vm.warp(block.timestamp + MIN_DELAY + 1);

        // 4. Execute
        governor.execute(addressesToCall, values, functionCalls, descriptionHash);

        assert(box.retrieve() == valueToStore);
    }
}


