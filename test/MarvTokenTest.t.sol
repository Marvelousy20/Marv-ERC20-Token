// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/test.sol";

import {DeployMarvToken} from "script/DeployMarvToken.s.sol";
import {MarvToken} from "src/MarvToken.sol";

contract MarvTokenTest is Test {
    MarvToken marvToken;

    address olawale = makeAddr("olawale");
    address tobi = makeAddr("tobi");
    address otherUser = makeAddr("otheruser");
    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public constant INITIAL_ALLOWANCE = 1000;

    function setUp() external {
        DeployMarvToken deployer = new DeployMarvToken();
        marvToken = deployer.run();

        vm.prank(msg.sender);
        marvToken.transfer(olawale, STARTING_BALANCE);
    }

    function testOlawaleBalanceIsCorrect() public {
        assertEq(STARTING_BALANCE, marvToken.balanceOf(olawale));
    }

    function testAllowanceWorks() public {
        // Olawale approves tobi to spend 1000 of his token.
        vm.prank(olawale);
        marvToken.approve(tobi, INITIAL_ALLOWANCE);

        // Tobi then spends the token
        uint256 transferAmount = 500;

        vm.prank(tobi);
        marvToken.transferFrom(olawale, tobi, transferAmount);

        assertEq(marvToken.balanceOf(tobi), transferAmount);
        assertEq(
            marvToken.balanceOf(olawale),
            STARTING_BALANCE - transferAmount
        );

        // Allowance Balance
        assertEq(
            marvToken.allowance(olawale, tobi),
            INITIAL_ALLOWANCE - transferAmount
        );
    }

    // Test: Transfer works correctly
    function testTransferWorks() public {
        vm.prank(olawale);
        uint256 transferAmount = 10 ether;

        marvToken.transfer(tobi, transferAmount);
        assertEq(marvToken.balanceOf(tobi), transferAmount);
        assertEq(
            marvToken.balanceOf(olawale),
            STARTING_BALANCE - transferAmount
        );
    }

    // Test: Transfer fails if sender has insufficent balance
    function testFailsWhenSenderBalanceIsInsufficient() public {
        vm.prank(olawale);

        bool success = marvToken.transfer(tobi, 2000 ether);
        assert(success != true);
    }

    // Test: TransferFrom fails if allowance is insufficent
    function testTransferFromFailsIfAllowanceIsInsufficient() public {
        vm.prank(olawale);

        marvToken.approve(tobi, INITIAL_ALLOWANCE);

        uint256 value = 2000;

        // tobi tries to spend more than olawale approves'
        vm.prank(tobi);
        vm.expectRevert();
        marvToken.transferFrom(olawale, tobi, 2000);
    }

    // Test: Approving zero then a new amount works
    function testApproveReset() public {
        vm.prank(olawale);
        marvToken.approve(tobi, INITIAL_ALLOWANCE);

        // Reset allowance to zero
        vm.prank(olawale);
        marvToken.approve(tobi, 0);
        assertEq(marvToken.allowance(olawale, tobi), 0);

        // Approve again with a new amount
        vm.prank(olawale);
        marvToken.approve(tobi, 50 ether);
        assertEq(marvToken.allowance(olawale, tobi), 50 ether);
    }

    // Test: minting
    function testMinting() public {
        uint256 mintAmount = 10 ether;
        uint256 initialTotalSupply = marvToken.totalSupply();
        uint256 initialBalance = marvToken.balanceOf(olawale);

        vm.prank(msg.sender);
        marvToken._mint(olawale, mintAmount);

        // Olawale's balance is meant to increase by the mintAmount
        assertEq(marvToken.balanceOf(olawale), initialBalance + mintAmount);

        // The totalSupply should now be the initialTotalSupply + mintingAmount
        assertEq(marvToken.totalSupply(), initialTotalSupply + mintAmount);
    }
}
