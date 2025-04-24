// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Script, console2} from "forge-std/Script.sol";
import {CrowdLiquidityRegistrar} from "../src/CrowdLiquidityRegistrar.sol";
import {
    EcoChainCrowdLiquidityCheckModule
} from "../src/EcoChainCrowdLiquidityCheckModule.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address admin = vm.addr(deployerPrivateKey);

        // Deploy CrowdLiquidityRegistrar
        CrowdLiquidityRegistrar registrar = new CrowdLiquidityRegistrar(admin);
        console2.log(
            "CrowdLiquidityRegistrar deployed at:",
            address(registrar)
        );

        // Deploy EcoChainCrowdLiquidityCheckModule
        EcoChainCrowdLiquidityCheckModule module = new EcoChainCrowdLiquidityCheckModule(
                registrar
            );
        console2.log(
            "EcoChainCrowdLiquidityCheckModule deployed at:",
            address(module)
        );

        vm.stopBroadcast();
    }
}
