// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../../contracts/Treasury.sol";

contract ReentrantHolder {
    Treasury t;
    bool public reentered;
    receive() external payable {
        if (msg.sender == address(t)) {
            try t.Redeem() { reentered = true; } catch {}
        }
    }
    function arm(Treasury _t) external { t = _t; }
    function redeem() external { t.Redeem(); }
}

contract RejectingHolder {
    function redeem(Treasury t) external { t.Redeem(); }
}

/// Pays with Solidity's transfer, which forwards only 2,300 gas.
contract LowGasPayer {
    function pay(address to) external payable { payable(to).transfer(msg.value); }
}

contract TreasuryTest is Test {
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address carol = makeAddr("carol");
    Treasury t;

    function setUp() public {
        vm.prank(alice);
        t = new Treasury("Plus", "PLS", 1000, 0);
        vm.deal(address(this), 1e30);
    }

    function pay(uint amount) internal {
        (bool ok, ) = address(t).call{value: amount}("");
        assertTrue(ok);
    }

    function owed(address who) internal returns (uint) {
        vm.prank(who);
        return t.View_Account();
    }

    function test_ConstructorRejectsAZeroSupply() public {
        vm.expectRevert("supply is required");
        new Treasury("Plus", "PLS", 0, 0);
    }

    function test_DeployerHoldsTheFullSupply() public {
        assertEq(t.balanceOf(alice), 1000);
        assertEq(t.CountRegisterdShards(), 1000);
    }

    function test_DecimalsArgumentSetsTokenDecimals() public {
        vm.prank(alice);
        Treasury d = new Treasury("Plus", "PLS", 1000, 2);
        assertEq(d.totalSupply(), 100000);
        assertEq(d.decimals(), 2);
    }

    function test_HoldersEarnWithoutRegistering() public {
        vm.prank(alice);
        t.transfer(bob, 400);
        pay(1000 ether);
        assertEq(owed(alice), 600 ether);
        assertEq(owed(bob), 400 ether);
        vm.prank(alice);
        t.Redeem();
        vm.prank(bob);
        t.Redeem();
        assertEq(alice.balance, 600 ether);
        assertEq(bob.balance, 400 ether);
    }

    function test_RegisterAccountIsHarmlessAndRepeatable() public {
        vm.startPrank(bob);
        assertTrue(t.Register_Account());
        assertTrue(t.Register_Account());
        vm.stopPrank();
    }

    function test_EarningsStayWithWhoeverHeldTheTokens() public {
        pay(100 ether);
        vm.prank(alice);
        t.transfer(bob, 1000);
        pay(50 ether);
        assertEq(owed(alice), 100 ether);
        assertEq(owed(bob), 50 ether);
    }

    function test_ASellerCanStillRedeemAfterSellingEverything() public {
        pay(100 ether);
        vm.prank(alice);
        t.transfer(bob, 1000);
        vm.prank(alice);
        t.Redeem();
        assertEq(alice.balance, 100 ether);
    }

    function test_AHolderWithZeroBalanceBlocksNothing() public {
        vm.prank(alice);
        t.transfer(bob, 1000);
        pay(1000 ether);
        assertEq(owed(bob), 1000 ether);
    }

    function test_SmallPaymentsAreNotLost() public {
        vm.prank(alice);
        Treasury big = new Treasury("Plus", "PLS", 1000, 18);
        for (uint i = 0; i < 3; i++) {
            (bool ok, ) = address(big).call{value: 333 ether}("");
            assertTrue(ok);
        }
        vm.prank(alice);
        assertApproxEqAbs(big.View_Account(), 999 ether, 1); // rounding keeps at most 1 wei back
    }

    function test_PaymentsBelowTheSupplyAccumulate() public {
        for (uint i = 0; i < 1000; i++) {
            pay(1);
        }
        assertEq(owed(alice), 1000);
    }

    function test_RedeemTwiceFails() public {
        pay(1 ether);
        vm.startPrank(alice);
        t.Redeem();
        vm.expectRevert("account value 0");
        t.Redeem();
        vm.stopPrank();
    }

    function test_ReentrantRedeemPaysOnce() public {
        ReentrantHolder h = new ReentrantHolder();
        h.arm(t);
        vm.prank(alice);
        t.transfer(address(h), 500);
        pay(1000 ether);
        h.redeem();
        assertFalse(h.reentered());
        assertEq(address(h).balance, 500 ether);
        assertEq(address(t).balance, 500 ether);
    }

    function test_FailedPayoutKeepsTheCredit() public {
        RejectingHolder h = new RejectingHolder();
        vm.prank(alice);
        t.transfer(address(h), 500);
        pay(1000 ether);
        vm.expectRevert("payment failed");
        h.redeem(t);
        vm.prank(address(h));
        assertEq(t.View_Account(), 500 ether);
    }

    function test_KnownLimit_LowGasSendersCannotPay() public {
        LowGasPayer payer = new LowGasPayer();
        vm.expectRevert();
        payer.pay{value: 1 ether}(address(t));
    }

    function testFuzz_NobodyWithdrawsMoreThanWasPaid(uint64[6] memory payments, uint16[6] memory moves, uint8[6] memory who) public {
        address[3] memory holders = [alice, bob, carol];
        uint totalPaid;
        for (uint i = 0; i < 6; i++) {
            uint amount = payments[i];
            pay(amount);
            totalPaid += amount;
            address from = holders[who[i] % 3];
            address to = holders[(uint(who[i]) + 1) % 3];
            uint move = bound(moves[i], 0, t.balanceOf(from));
            vm.prank(from);
            t.transfer(to, move);
        }
        uint sumOwed = owed(alice) + owed(bob) + owed(carol);
        assertLe(sumOwed, totalPaid);
        assertLe(totalPaid - sumOwed, 3); // at most one wei of rounding per holder
        for (uint i = 0; i < 3; i++) {
            if (owed(holders[i]) > 0) {
                vm.prank(holders[i]);
                t.Redeem();
            }
        }
        assertEq(alice.balance + bob.balance + carol.balance + address(t).balance, totalPaid);
        assertLe(address(t).balance, 3);
    }
}
