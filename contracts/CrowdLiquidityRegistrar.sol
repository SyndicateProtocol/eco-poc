// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import {
    ICrowdLiquidityRegistrar
} from "./interfaces/ICrowdLiquidityRegistrar.sol";

/// @title CrowdLiquidityRegistrar
/// @notice Manages the crowd liquidity addresses
/// @dev Controls crowd liquidity addresses with admin management
contract CrowdLiquidityRegistrar is ICrowdLiquidityRegistrar, AccessControl {
    // Role definitions
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    struct CrowdLiquidityElement {
        uint256 crowdLiquidityId;
        address crowdLiquidityAddress;
        bool isValid;
    }

    uint256 private _crowdLiquidityCount;
    bool private _isCrowdLiquidityLocked;

    // Mapping from crowd liquidity ID to CrowdLiquidityElement
    mapping(uint256 => CrowdLiquidityElement) public crowdLiquidityElements;

    // Mapping from crowd liquidity address to crowd liquidity ID
    mapping(address => uint256) public crowdLiquidityAddressToId;

    /// /// /// /// /// /// /// /// /// /// /// /// /// /// ///

    /// @notice Initialize the contract with necessary addresses
    /// @param admin The admin address for the contract
    constructor(address admin) {
        if (admin == address(0)) revert InvalidAddress();

        _crowdLiquidityCount = 1;
        _isCrowdLiquidityLocked = false;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
    }

    /// /// /// /// /// /// /// /// /// /// /// /// /// /// ///

    /**
     * @notice Get the crowd liquidity locked status
     * @return The crowd liquidity locked status
     */
    function isCrowdLiquidityLocked() external view override returns (bool) {
        return _isCrowdLiquidityLocked;
    }

    /**
     * @notice Lock the contract
     */
    function lockCrowdLiquidity() external override onlyRole(ADMIN_ROLE) {
        if (_isCrowdLiquidityLocked) revert CrowdLiquidityAlreadyLocked();
        _isCrowdLiquidityLocked = true;
    }

    /**
     * @notice Unlock the contract
     */
    function unlockCrowdLiquidity() external override onlyRole(ADMIN_ROLE) {
        if (!_isCrowdLiquidityLocked) revert CrowdLiquidityNotLocked();
        _isCrowdLiquidityLocked = false;
    }

    /// /// /// /// /// /// /// /// /// /// /// /// /// /// ///

    /**
     * @notice Get the crowd liquidity count
     * @return The crowd liquidity count
     */
    function crowdLiquidityCount() external view override returns (uint256) {
        return _crowdLiquidityCount;
    }

    /**
     * @notice Adds a new crowd liquidity address
     * @param crowdLiquidityAddress The address of the crowd liquidity to add
     * @return crowdLiquidityId The ID of the added crowd liquidity
     */
    function addCrowdLiquidityAddress(
        address crowdLiquidityAddress
    )
        external
        override
        onlyRole(ADMIN_ROLE)
        returns (uint256 crowdLiquidityId)
    {
        if (crowdLiquidityAddress == address(0)) revert InvalidAddress();

        // Check if the address is already added
        if (crowdLiquidityAddressToId[crowdLiquidityAddress] != 0) {
            revert CrowdLiquidityAddressAlreadyAdded();
        }

        // Increment the crowd liquidity count
        uint256 idUsed = _crowdLiquidityCount++;

        // Add the crowd liquidity address to the mapping
        crowdLiquidityAddressToId[crowdLiquidityAddress] = idUsed;

        // Add the crowd liquidity address to the elements mapping
        crowdLiquidityElements[idUsed] = CrowdLiquidityElement({
            crowdLiquidityId: idUsed,
            crowdLiquidityAddress: crowdLiquidityAddress,
            isValid: true
        });

        emit CrowdLiquidityAdded(idUsed, crowdLiquidityAddress);

        return idUsed;
    }

    /**
     * @notice Reinstate a crowd liquidity address after it has been removed
     * @param crowdLiquidityAddress The address of the crowd liquidity to reinstate
     * @return crowdLiquidityId The ID of the reinstated crowd liquidity
     */
    function reinstateCrowdLiquidityAddress(
        address crowdLiquidityAddress
    )
        external
        override
        onlyRole(ADMIN_ROLE)
        returns (uint256 crowdLiquidityId)
    {
        if (crowdLiquidityAddress == address(0)) revert InvalidAddress();

        // Get the crowd liquidity ID
        crowdLiquidityId = crowdLiquidityAddressToId[crowdLiquidityAddress];

        // Check if the crowd liquidity ID is valid
        if (crowdLiquidityId == 0) revert CrowdLiquidityAddressNotFound();

        // Set the crowd liquidity address to valid
        crowdLiquidityElements[crowdLiquidityId].isValid = true;

        // Emit the event
        emit CrowdLiquidityReinstated(crowdLiquidityId, crowdLiquidityAddress);

        return crowdLiquidityId;
    }

    /**
     * @notice Remove a crowd liquidity address
     * @param crowdLiquidityAddress The address of the crowd liquidity to remove
     * @return crowdLiquidityId The ID of the removed crowd liquidity
     */
    function removeCrowdLiquidityAddress(
        address crowdLiquidityAddress
    )
        external
        override
        onlyRole(ADMIN_ROLE)
        returns (uint256 crowdLiquidityId)
    {
        if (crowdLiquidityAddress == address(0)) revert InvalidAddress();

        // Get the crowd liquidity ID
        crowdLiquidityId = crowdLiquidityAddressToId[crowdLiquidityAddress];

        // Check if the crowd liquidity ID is valid
        if (
            crowdLiquidityId == 0 ||
            !crowdLiquidityElements[crowdLiquidityId].isValid
        ) {
            revert CrowdLiquidityAddressNotFound();
        }

        // Set the crowd liquidity address to invalid
        crowdLiquidityElements[crowdLiquidityId].isValid = false;

        // Emit the event
        emit CrowdLiquidityRemoved(crowdLiquidityId, crowdLiquidityAddress);

        return crowdLiquidityId;
    }

    /**
     * @notice Check if a crowd liquidity address is valid
     * @param crowdLiquidityAddress The address to check
     * @return bool indicating if the crowd liquidity address is valid
     */
    function isCrowdLiquidityAddress(
        address crowdLiquidityAddress
    ) external view override returns (bool) {
        if (crowdLiquidityAddress == address(0)) return false;

        // Get the crowd liquidity ID
        uint256 crowdLiquidityId = crowdLiquidityAddressToId[
            crowdLiquidityAddress
        ];

        // Check if the crowd liquidity ID is valid
        CrowdLiquidityElement
            storage crowdLiquidityElement = crowdLiquidityElements[
                crowdLiquidityId
            ];

        // Return the validity of the crowd liquidity address
        return crowdLiquidityElement.isValid;
    }

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
        override
        returns (
            uint256 crowdLiquidityId,
            address crowdLiquidityAddress,
            bool isValid
        )
    {
        return
            _getCrowdLiquidityById(
                crowdLiquidityAddressToId[crowdLiquidityAddress]
            );
    }

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
        override
        returns (
            uint256 crowdLiquidityId,
            address crowdLiquidityAddress,
            bool isValid
        )
    {
        return _getCrowdLiquidityById(crowdLiquidityId);
    }

    /**
     * @notice Get all crowd liquidity information given the crowd liquidity ID
     * @param crowdLiquidityId The ID of the crowd liquidity
     * @return crowdLiquidityAddress The address of the crowd liquidity
     * @return isValid The validity of the crowd liquidity address
     */
    function _getCrowdLiquidityById(
        uint256 crowdLiquidityId
    )
        internal
        view
        returns (
            uint256 crowdLiquidityId,
            address crowdLiquidityAddress,
            bool isValid
        )
    {
        if (crowdLiquidityId == 0) revert InvalidAddress();

        CrowdLiquidityElement
            storage crowdLiquidityElement = crowdLiquidityElements[
                crowdLiquidityId
            ];

        if (!crowdLiquidityElement.isValid)
            revert CrowdLiquidityAddressNotFound();

        return (
            crowdLiquidityId,
            crowdLiquidityAddress,
            crowdLiquidityElement.isValid
        );
    }
}
