// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import {
    ICalldataPermissionModule
} from "./interfaces/ICalldataPermissionModule.sol";

import {
    ICrowdLiquidityRegistrar
} from "./interfaces/ICrowdLiquidityRegistrar.sol";

import {
    IEcoChainCrowdLiquidityCheckModule
} from "./interfaces/IEcoChainCrowdLiquidityCheckModule.sol";

import {RLPTxBreakdown} from "./RLP/RLPTxBreakdown.sol";

/**
 * @title EcoChainCrowdLiquidityCheckModule
 * @dev it checks whether caller is allowed from calldata.
 */
contract EcoChainCrowdLiquidityCheckModule is
    IEcoChainCrowdLiquidityCheckModule,
    ICalldataPermissionModule,
    AccessControl
{
    // The crowd liquidity registrar
    ICrowdLiquidityRegistrar private _crowdLiquidityRegistrar;

    // Role for updating the crowd liquidity registrar
    bytes32 public constant UPDATE_CROWD_LIQUIDITY_REGISTRAR_ROLE =
        keccak256("UPDATE_CROWD_LIQUIDITY_REGISTRAR_ROLE");

    /**
     * @notice Construct the EcoChainCrowdLiquidityCheckModule
     * @param crowdLiquidityRegistrar_ The address of the CrowdLiquidityRegistrar contract
     */
    constructor(ICrowdLiquidityRegistrar crowdLiquidityRegistrar_) {
        if (address(crowdLiquidityRegistrar_) == address(0)) {
            revert EmptyAddress();
        }

        _crowdLiquidityRegistrar = crowdLiquidityRegistrar_;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPDATE_CROWD_LIQUIDITY_REGISTRAR_ROLE, msg.sender);
    }

    /**
     * @notice Updates the crowd liquidity registrar
     * @param crowdLiquidityRegistrar_ The address of the CrowdLiquidityRegistrar contract
     */
    function updateCrowdLiquidityRegistrar(
        address crowdLiquidityRegistrar_
    ) external override onlyRole(UPDATE_CROWD_LIQUIDITY_REGISTRAR_ROLE) {
        if (address(crowdLiquidityRegistrar_) == address(0)) {
            revert EmptyAddress();
        }

        _crowdLiquidityRegistrar = crowdLiquidityRegistrar_;

        emit CrowdLiquidityRegistrarUpdated(
            // @dev old crowd liquidity registrar
            address(_crowdLiquidityRegistrar),
            // @dev new crowd liquidity registrar
            crowdLiquidityRegistrar_
        );
    }

    /**
     * @notice The crowd liquidity registrar
     * @return The address of the CrowdLiquidityRegistrar contract
     */
    function crowdLiquidityRegistrar()
        external
        view
        override
        returns (ICrowdLiquidityRegistrar)
    {
        return _crowdLiquidityRegistrar;
    }

    /**
     * @notice checks if calldata to address is a crowd liquidity address and if so, do not allow it.
     * @return bool indicating whether is allowed.
     */
    function isCalldataAllowed(
        bytes calldata data
    ) external view override returns (bool) {
        // Check if the crowd liquidity is locked
        if (_crowdLiquidityRegistrar.isCrowdLiquidityLocked()) {
            // Decode the transaction calldata
            (, , , , address to, ) = RLPTxBreakdown.decodeTx(data);

            // Check if the to address is a crowd liquidity address
            if (_crowdLiquidityRegistrar.isCrowdLiquidityAddress(to)) {
                // If so, do not allow it
                return false;
            }
        }

        return true;
    }
}
