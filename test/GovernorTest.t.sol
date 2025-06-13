// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {Test} from 'forge-std/Test.sol';
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

}
