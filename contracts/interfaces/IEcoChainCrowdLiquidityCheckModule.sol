// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {
    ICrowdLiquidityRegistrar
} from "./interfaces/ICrowdLiquidityRegistrar.sol";

/**
 * @title IEcoChainCrowdLiquidityCheckModule
 * @dev it checks whether caller is allowed from calldata.
 */
interface IEcoChainCrowdLiquidityCheckModule {
    /**
     * @notice Event for updating the crowd liquidity registrar
     * @param oldCrowdLiquidityRegistrar The address of the old CrowdLiquidityRegistrar contract
     * @param newCrowdLiquidityRegistrar The address of the new CrowdLiquidityRegistrar contract
     */
    event CrowdLiquidityRegistrarUpdated(
        address indexed oldCrowdLiquidityRegistrar,
        address indexed newCrowdLiquidityRegistrar
    );

    /**
     * @notice Error for empty address
     */
    error EmptyAddress();

    /**
     * @notice Updates the crowd liquidity registrar
     * @param _crowdLiquidityRegistrar The address of the CrowdLiquidityRegistrar contract
     */
    function updateCrowdLiquidityRegistrar(
        address _crowdLiquidityRegistrar
    ) external;

    /**
     * @notice The crowd liquidity registrar
     * @return The address of the CrowdLiquidityRegistrar contract
     */
    function crowdLiquidityRegistrar()
        external
        view
        returns (ICrowdLiquidityRegistrar);
}
