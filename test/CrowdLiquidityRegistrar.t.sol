// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {CrowdLiquidityRegistrar} from "../src/CrowdLiquidityRegistrar.sol";

contract CrowdLiquidityRegistrarTest is Test {
    CrowdLiquidityRegistrar public registrar;
    address public admin = address(0x1);

    function setUp() public {
        vm.startPrank(admin);
        registrar = new CrowdLiquidityRegistrar(admin);
        vm.stopPrank();
    }

    function test_Initialize() public {
        assertEq(registrar.isCrowdLiquidityLocked(), false);
        assertEq(registrar.crowdLiquidityCount(), 1);
    }

    function test_AddCrowdLiquidity() public {
        address crowdLiquidityAddress = address(0x2);

        vm.startPrank(admin);
        uint256 id = registrar.addCrowdLiquidityAddress(crowdLiquidityAddress);
        vm.stopPrank();

        assertEq(id, 1);
        assertTrue(registrar.isCrowdLiquidityAddress(crowdLiquidityAddress));
    }
}
