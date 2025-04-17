// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

/// @title ICrowdLiquidityRegistrar
/// @notice Interface for crowd liquidity address checks
interface ICrowdLiquidityRegistrar {
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

    /// /// /// /// /// /// /// /// /// /// /// /// /// /// ///

    // Errors
    error CrowdLiquidityAlreadyLocked();
    error CrowdLiquidityNotLocked();
    error CrowdLiquidityAddressNotFound();
    error CrowdLiquidityAddressAlreadyAdded();
    error InvalidAddress();

    /// /// /// /// /// /// /// /// /// /// /// /// /// /// ///

    /**
     * @notice The admin role for the CrowdLiquidityRegistrar contract
     * @return The admin role
     */
    function ADMIN_ROLE() external view returns (bytes32);

    /**
     * @notice Check if an address has a role
     * @dev Returns `true` if `account` has been granted `role`.
     * @param role The role to check
     * @param account The address to check
     * @return bool indicating if the address has the role
     */
    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool);

    /**
     * @notice Add a crowd liquidity address
     * @param crowdLiquidityAddress The address to add
     * @return crowdLiquidityId The ID of the added crowd liquidity address
     */
    function addCrowdLiquidityAddress(
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
     * @param crowdLiquidityAddress The address of the crowd liquidity
     * @return crowdLiquidityId The ID of the crowd liquidity
     * @return crowdLiquidityAddress The address of the crowd liquidity
     * @return isValid The validity of the crowd liquidity address
     */
    function getCrowdLiquidityByAddress(
        address crowdLiquidityAddress
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
     * @return crowdLiquidityAddress The address of the crowd liquidity
     * @return isValid The validity of the crowd liquidity address
     */
    function getCrowdLiquidityById(
        uint256 crowdLiquidityId
    )
        external
        view
        returns (
            uint256 crowdLiquidityId,
            address crowdLiquidityAddress,
            bool isValid
        );
}
