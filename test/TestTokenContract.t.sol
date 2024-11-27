// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "lib/forge-std/src/Test.sol";
import {TokenContract} from "src/TokenContract.sol";
import {DeployTokenContract} from "script/DeployTokenContract.s.sol";

contract TestTokenContract is Test {
    DeployTokenContract deployTokenContract;
    TokenContract tokenContract;
    address public USER = makeAddr("user");
    address public MINTER = makeAddr("minter");
    address public OWNER;

    function setUp() public {
        deployTokenContract = new DeployTokenContract();
        tokenContract = deployTokenContract.run();
        vm.deal(USER, 2 ether);
        vm.deal(MINTER, 2 ether);
        OWNER = tokenContract.owner();
        require(OWNER != address(0), "Owner should not be the zero address");
    }

    function testInitialSupply() external view {
        uint256 initialSupply = tokenContract.totalSupply();
        assertEq(initialSupply, 50_000 * 10 ** 18);  
    }

    function testMint() external {
        uint256 amount = 1000 * 10 ** 18;
        vm.prank(MINTER);  
        tokenContract.mint(USER, amount);  
        uint256 balance = tokenContract.balanceOf(USER);
        assertEq(balance, amount);  
    }

    function testExceedMaxBalancePerAddress() external {
        uint256 amount = 60_000 * 10 ** 18;  
        vm.prank(MINTER);
        vm.expectRevert(TokenContract.Token__MaxBalanceExceeded.selector);  
        tokenContract.mint(USER, amount); 
    }

    function testExceedMaxSupply() external {
        uint256 amount = 1_000_000 * 10 ** 18;  
        vm.prank(MINTER);
        vm.expectRevert(TokenContract.Token__MaxSupplyExceeded.selector);  
        tokenContract.mint(USER, amount);  
    }

    function testMintToZeroAddress() external {
        uint256 amount = 1000 * 10 ** 18;
        vm.prank(MINTER);
        vm.expectRevert(TokenContract.Token__CannotMintToZeroAddress.selector);  
        tokenContract.mint(address(0), amount);  
    }

    function testOwnerCanUpdateMaxBalance() external {
        uint256 newMaxBalance = 100_000 * 10 ** 18;
        vm.prank(OWNER);  
        tokenContract.updateMaxBalancePerAddress(newMaxBalance);
        uint256 maxBalance = tokenContract.s_maxBalancePerAddress();
        assertEq(maxBalance, newMaxBalance);  
    }
}
