// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {RLPReader} from "./RLPReader.sol";

/**
 * @title RLPTxBreakdown
 * @notice A library for decoding raw EIP-1559 transactions and breaking them down into their components.
 * @dev This library expects a raw transaction beginning with 0x02 and 12 RLP items.
 */
library RLPTxBreakdown {
    using RLPReader for bytes;
    using RLPReader for RLPReader.RLPItem;

    /**
     * @notice Decode an Ethereum transaction.
     * @param txData The raw transaction data.
     * @return chainId The chain ID of the transaction
     * @return nonce The nonce of the transaction
     * @return value The value of the transaction
     * @return data The data of the transaction
     * @return to The recipient address of the transaction
     * @return from The sender address of the transaction
     */
    function decodeTx(
        bytes calldata txData
    )
        external
        pure
        returns (
            uint256 chainId,
            uint256 nonce,
            // uint256 _maxPriorityFeePerGas,
            // uint256 _maxFeePerGas,
            // uint256 _gasLimit,
            uint256 value,
            bytes memory data,
            address to,
            address from
        )
    {
        require(txData.length > 0, "Empty tx");
        require(txData[0] == 0x02, "Not EIP-1559");
        // Remove the type byte.
        bytes memory rlpTx = _slice(txData, 1, txData.length - 1);
        RLPReader.RLPItem memory txItem = rlpTx.toRlpItem();
        RLPReader.RLPItem[] memory items = txItem.toList();
        require(items.length == 12, "Invalid tx");

        // Build unsigned payload from first 9 RLP items.
        bytes memory unsignedPayload = abi.encodePacked(
            // chainId - Chain ID of the network (for example, 1 for Ethereum Mainnet).
            items[0].toRlpBytes(),
            // nonce - Transaction nonce of the sender account.
            items[1].toRlpBytes(),
            // maxPriorityFeePerGas - Tip cap (max priority fee per gas the sender is willing to pay).
            items[2].toRlpBytes(),
            // maxFeePerGas - Max total fee (inclusive of base fee and tip) the sender will pay.
            items[3].toRlpBytes(),
            // gasLimit - Gas limit for the transaction.
            items[4].toRlpBytes(),
            // to - Recipient address (20-byte Ethereum address). This is an empty byte string if the transaction is contract creation.
            items[5].toRlpBytes(),
            // value - Amount of ETH (in wei) to transfer.
            items[6].toRlpBytes(),
            // data - Transaction payload (the calldata for a contract call, or contract creation bytecode).
            items[7].toRlpBytes(),
            // accessList - EIP-2930 access list (list of address/storage key tuples); can be an empty list.
            items[8].toRlpBytes()
        );

        // Use different variable names to avoid shadowing
        uint256 _chainId = items[0].toUint();
        uint256 _nonce = items[1].toUint();
        // uint256 _maxPriorityFeePerGas = items[2].toUint();
        // uint256 _maxFeePerGas = items[3].toUint();
        // uint256 _gasLimit = items[4].toUint();
        uint256 _value = items[6].toUint();
        bytes memory _data = items[7].toBytes();
        address _to = items[5].toAddress();
        address _from = _getAddress(unsignedPayload, items);

        return (_chainId, _nonce, _value, _data, _to, _from);
    }

    /**
     * @notice Given the unsigned payload, recovers the sender address.
     * @param unsignedPayload The unsigned payload of the transaction.
     * @param items The RLP items of the transaction.
     * @return sender The sender address
     */
    function _getAddress(
        bytes memory unsignedPayload,
        RLPReader.RLPItem[] memory items
    ) internal pure returns (address sender) {
        // RLP-encode the unsigned payload.
        bytes memory encodedUnsigned;
        if (unsignedPayload.length < 56) {
            encodedUnsigned = abi.encodePacked(
                uint8(0xc0 + unsignedPayload.length),
                unsignedPayload
            );
        } else {
            uint256 len = unsignedPayload.length;
            uint256 lenLen;
            uint256 tmp = len;
            while (tmp != 0) {
                lenLen++;
                tmp >>= 8;
            }
            bytes memory lenBytes = new bytes(lenLen);
            tmp = len;
            for (uint256 i = 0; i < lenLen; i++) {
                lenBytes[lenLen - 1 - i] = bytes1(uint8(tmp & 0xFF));
                tmp >>= 8;
            }
            encodedUnsigned = abi.encodePacked(
                uint8(0xf7 + lenLen),
                lenBytes,
                unsignedPayload
            );
        }
        // Prepend type byte 0x02.
        bytes32 msgHash = keccak256(
            abi.encodePacked(bytes1(0x02), encodedUnsigned)
        );

        // Adjust v and recover the sender address.
        uint8 v = uint8(uint256(items[9].toUint())) + 27;
        bytes32 r = _toBytes32(items[10]);
        bytes32 s = _toBytes32(items[11]);
        return ecrecover(msgHash, v, r, s);
    }

    /**
     * @notice Internal helper function to slice a byte array.
     * @param data The byte array.
     * @param start The start index.
     * @param len The number of bytes to slice.
     * @return A new byte array containing the slice.
     */
    function _slice(
        bytes memory data,
        uint256 start,
        uint256 len
    ) internal pure returns (bytes memory) {
        bytes memory result = new bytes(len);
        for (uint256 i = 0; i < len; i++) {
            result[i] = data[i + start];
        }
        return result;
    }

    /**
     * @notice Internal helper to convert an RLP item to a bytes32 value.
     * @param item The RLP item.
     * @return result The bytes32 representation.
     */
    function _toBytes32(
        RLPReader.RLPItem memory item
    ) internal pure returns (bytes32 result) {
        bytes memory b = item.toBytes();
        require(b.length <= 32, "Invalid length");
        assembly {
            result := mload(add(b, 32))
        }
    }
}
