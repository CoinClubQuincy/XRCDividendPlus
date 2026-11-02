// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../../contracts/Treasury.sol";

/// Tests whose names start with test_KnownIssue pin current behaviour that is a defect.
contract TreasuryTest is Test {
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    Treasury t;

    function setUp() public {
        vm.prank(alice);
        t = new Treasury("Plus", "PLS", 1000, 0);
        vm.deal(address(this), 100000 ether);
    }

    function pay(uint amount) internal returns (bool ok) {
        (ok, ) = address(t).call{value: amount}("");
    }

    function test_DeployerIsRegisteredWithFullSupply() public {
        assertEq(t.balanceOf(alice), 1000);
        assertEq(t.CountRegisterdShards(), 1000);
    }

    function test_DividendsFollowRegisteredBalances() public {
        vm.prank(alice);
        t.transfer(bob, 400);
        vm.prank(bob);
        t.Register_Account();
        assertTrue(pay(1000 ether));
        vm.prank(alice);
        t.Redeem();
        vm.prank(bob);
        t.Redeem();
        assertEq(alice.balance, 600 ether);
        assertEq(bob.balance, 400 ether);
    }

    function test_UnregisteredHolderIsLeftOutOfTheSplit() public {
        vm.prank(alice);
        t.transfer(bob, 400);
        assertTrue(pay(600 ether));
        vm.prank(alice);
        t.Redeem();
        assertEq(alice.balance, 600 ether);
        vm.prank(bob);
        vm.expectRevert("User does not exist");
        t.Redeem();
    }

    function test_KnownIssue_DecimalsArgumentDoesNotChangeTokenDecimals() public {
        vm.prank(alice);
        Treasury d = new Treasury("Plus", "PLS", 1000, 2);
        assertEq(d.totalSupply(), 100000);
        assertEq(d.decimals(), 18);
    }

    function test_KnownIssue_PaymentSmallerThanSupplyAllocatesNothing() public {
        vm.prank(alice);
        Treasury big = new Treasury("Plus", "PLS", 1000, 18);
        (bool ok, ) = address(big).call{value: 999 ether}("");
        assertTrue(ok);
        assertEq(address(big).balance, 999 ether);
        vm.prank(alice);
        assertEq(big.View_Account(), 0);
    }

    function test_KnownIssue_RegisteredHolderWithZeroBalanceBlocksAllPayments() public {
        vm.prank(alice);
        t.transfer(bob, 1000);
        vm.prank(bob);
        t.Register_Account();
        assertFalse(pay(1000 ether));
    }
}
