// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;
import {
    IAccessControl
} from "@openzeppelin/contracts/access/IAccessControl.sol";

/**
 * @title ICrowdLiquidityRegistrar
 * @notice Interface for crowd liquidity address checks
 */
interface ICrowdLiquidityRegistrar is IAccessControl {
    // Events
    event CrowdLiquidityAdded(
        uint256 indexed crowdLiquidityId,
        address indexed crowdLiquidityAddress
    );

    event CrowdLiquidityRemoved(
        uint256 indexed crowdLiquidityId,
        address indexed crowdLiquidityAddress
    );

    event CrowdLiquidityReinstated(
        uint256 indexed crowdLiquidityId,
        address indexed crowdLiquidityAddress
    );

    /**
     * --------------------------------------------------------
     * --------------------------------------------------------
     */

    // Errors
    error CrowdLiquidityAlreadyLocked();
    error CrowdLiquidityNotLocked();
    error CrowdLiquidityAddressNotFound();
    error CrowdLiquidityAddressAlreadyAdded();
    error InvalidAddress();

    /**
     * --------------------------------------------------------
     * --------------------------------------------------------
     */

    /**
     * @notice The admin role for the CrowdLiquidityRegistrar contract
     * @return bytes32 The admin role
     */
    function ADMIN_ROLE() external view returns (bytes32);

    /**
     * @notice Check if the contract is locked
     * @return bool The locked status
     */
    function isCrowdLiquidityLocked() external view returns (bool);

    /**
     * @notice Lock the contract
     */
    function lockCrowdLiquidity() external;

    /**
     * @notice Unlock the contract
     */
    function unlockCrowdLiquidity() external;

    /**
     * @notice Get the crowd liquidity count
     * @return uint256 The count
     */
    function crowdLiquidityCount() external view returns (uint256);

    /**
     * @notice Add a crowd liquidity address
     * @param crowdLiquidityAddress The address to add
     * @return crowdLiquidityId The ID of the added crowd liquidity address
     */
    function addCrowdLiquidityAddress(
        address crowdLiquidityAddress
    ) external returns (uint256 crowdLiquidityId);

    /**
     * @notice Reinstate a crowd liquidity address after it has been removed
     * @param crowdLiquidityAddress The address of the crowd liquidity to reinstate
     * @return crowdLiquidityId The ID of the reinstated crowd liquidity
     */
    function reinstateCrowdLiquidityAddress(
        address crowdLiquidityAddress
    ) external returns (uint256 crowdLiquidityId);

    /**
     * @notice Remove a crowd liquidity address
     * @param crowdLiquidityAddress The address to remove
     * @return crowdLiquidityId The ID of the removed crowd liquidity address
     */
    function removeCrowdLiquidityAddress(
        address crowdLiquidityAddress
    ) external returns (uint256 crowdLiquidityId);

    /**
     * @notice Check if a crowd liquidity address is valid
     * @param crowdLiquidityAddress The address to check
     * @return bool indicating if the crowd liquidity address is valid
     */
    function isCrowdLiquidityAddress(
        address crowdLiquidityAddress
    ) external view returns (bool);

    /**
     * @notice Get all crowd liquidity information given the crowd liquidity address
     * @param crowdLiquidityAddr The address of the crowd liquidity
     * @return crowdLiquidityId The ID of the crowd liquidity
     * @return crowdLiquidityAddress The address of the crowd liquidity
     * @return isValid The validity of the crowd liquidity address
     */
    function getCrowdLiquidityByAddress(
        address crowdLiquidityAddr
    )
        external
        view
        returns (
            uint256 crowdLiquidityId,
            address crowdLiquidityAddress,
            bool isValid
        );

    /**
     * @notice Get all crowd liquidity information given the crowd liquidity ID
     * @param crowdLiquidityId The ID of the crowd liquidity
     * @return id The ID of the crowd liquidity
     * @return crowdLiquidityAddress The address of the crowd liquidity
     * @return isValid The validity of the crowd liquidity address
     */
    function getCrowdLiquidityById(
        uint256 crowdLiquidityId
    )
        external
        view
        returns (uint256 id, address crowdLiquidityAddress, bool isValid);
}
