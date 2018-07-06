pragma solidity ^0.4.24;

import "./KeyManagement.sol";

contract Identity {

    uint256 public constant MANAGEMENT_KEY = 1;
    uint256 public constant ACTION_KEY = 2;
    uint256 public constant CLAIM_KEY = 3;
    uint256 public constant ENCRYPTION_KEY = 4;

    uint256 public constant ECDSA = 1;
    uint256 public constant RSA = 2;

    uint256 public constant OPERATION_CALL = 0;
    uint256 public constant OPERATION_DELEGATECALL = 1;
    uint256 public constant OPERATION_CREATE = 2;

    using KeyManagement for KeyManagement.KeyManager;

    event KeyAdded(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
    event KeyRemoved(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);

    event ExecutedSigned(bytes32 signHash, uint256 nonce, bool success);
    event Received(address indexed sender, uint256 value);

    KeyManagement.KeyManager manager;

    uint256 nonce;

    constructor(address _owner) public {
        manager.addKey(bytes32(_owner), MANAGEMENT_KEY, ECDSA);
    }

    function () public payable { emit Received(msg.sender, msg.value); }

    function getKey(bytes32 _key) public view returns (uint256[], uint256, bytes32) {
        return manager.getKey(_key);
    }

    function getKeysByPurpose(uint256 _purpose) public view returns (bytes32[]) {
        return manager.getKeysByPurpose(_purpose);
    }

    function keyHasPurpose(bytes32 _key, uint256 _purpose) public view returns (bool) {
        return manager.keyHasPurpose(_key, _purpose);
    }

    function addKey(bytes32 _key, uint256 _purpose, uint256 _keyType) public returns (bool success) {
        if (isManagementAddress(msg.sender)) {
            success = manager.addKey(_key, _purpose, _keyType);
        }

        if (success) {
            emit KeyAdded(_key, _purpose, _keyType);
        }
    }

    function removeKey(bytes32 _key, uint256 _purpose) public returns (bool success) {
        if (isManagementAddress(msg.sender)) {
            uint256 keyType;
            (, keyType, ) = manager.getKey(_key);
            success = manager.removeKey(_key, _purpose);
        }

        if (success) {
            emit KeyRemoved(_key, _purpose, keyType);
        }
    }

    function isManagementAddress(address _subject) public view returns (bool) {
        return manager.keyHasPurpose(bytes32(_subject), MANAGEMENT_KEY);
    }

    function isActionAddress(address _subject) public view returns (bool) {
        return manager.keyHasPurpose(bytes32(_subject), ACTION_KEY);
    }

    function executeSigned(
        address _to,
        address _from,
        uint256 _value,
        bytes _data,
        uint256 _nonce,
        uint256 _gasPrice,
        uint256 _gasLimit,
        address _gasToken,
        uint256 _operationType,
        bytes _extraHash,
        bytes _messageSignatures
    ) public {
        // TODO: Implement ERC 1077.
    }

    function gasEstimate(
        address _to,
        address _from,
        uint256 _value,
        bytes _data,
        uint256 _nonce,
        uint256 _gasPrice,
        uint256 _gasLimit,
        address _gasToken,
        uint256 _operationType,
        bytes _extraHash,
        bytes _messageSignatures
    ) public view returns (bool canExecute, uint gasCost) {
        // TODO: Implement ERC 1077.
    }

    function lastNonce() public view returns (uint256) {
        return nonce;
    }

    function lastTimestamp() public view returns (uint256 timestamp) {
        // TODO: Implement ERC 1077.
    }

    function requiredSignatures(uint256 _keyType) public view returns (uint256 count) {
        // TODO: Implement ERC 1077.
    }

    // function execute(address _to, uint256 _value, bytes _data) external returns (bool) {
    //     if ((_to == address(this) && !isManagementAddress) && !isActionAddress(msg.sender)) return false;
    //     return _executeCall(_to, _value, _data);
    // }

    // function executeCallSigned(address _to, uint256 _value, bytes _data, bytes _sig) external returns (bool) {
    //     require(_to != address(this) && _to != address(0));
    //     bytes32 message = getExecuteCallSignedMessage(_to, _value, _data);
    //     require(meetsSignerThreshold(message, _sig));
    //     return _executeCall(_to, _value, _data);
    // }

    // function _executeCall(address _to, uint256 _value, bytes _data) internal returns (bool success) {
    //     require(_to != address(this) && _to != address(0));

    //     // increment nonce to prevent reentrancy
    //     nonce++;

    //     // solium-disable-next-line security/no-inline-assembly
    //     assembly {
    //         success := call(gas, _to, _value, add(_data, 0x20), mload(_data), 0, 0)
    //     }

    //     emit CallExecuted(_to, _value, _data, block.timestamp); // solium-disable-line security/no-block-members
    // }

    // Signer management
    // ===========================================================================

    // function getSigners() external view returns (address[]) {
    //     return signers;
    // }

    // function isSigner(address _address) public view returns (bool) {
    //     return signersMapping[_address];
    // }

    // function isSignerSignature(bytes32 message, bytes sig) public view returns (bool) {
    //     bytes32 hash = ECRecovery.toEthSignedMessageHash(message);
    //     return isSigner(ECRecovery.recover(hash, sig));
    // }

    // function addSigner(address _address) onlyOwner external {
    //     _addSigner(_address);
    // }

    // function addSignerSigned(address _address, bytes sig) external {
    //     bytes32 message = getAddOwnerSignedMessage(_address);
    //     require(isOwnerSignature(message, sig));
    //     _addSigner(_address);
    // }

    // function getAddSignerSignedMessage(address _address) public view returns (bytes32) {
    //     return keccak256(byte(0x19), byte(0), this, nonce, "addSigner", _address);
    // }

    // function _addSigner(address _address) internal {
    //     if (isOwner(_address) || isSigner(_address)) return;
    //     signersMapping[_address] = true;
    //     signers.push(_address);
    //     emit SignerAdded(_address, block.timestamp); // solium-disable-line security/no-block-members
    // }

    // function removeSigner(address _address) onlyOwner external {
    //     _removeSigner(_address);
    // }

    // function removeSignerSigned(address _address, bytes sig) external {
    //     bytes32 message = getRemoveSignerSignedMessage(_address);
    //     require(isOwnerSignature(message, sig));
    //     _removeSigner(_address);
    // }

    // function getRemoveSignerSignedMessage(address _address) public view returns (bytes32) {
    //     return keccak256(byte(0x19), byte(0), this, nonce, "removeSigner", _address);
    // }

    // function _removeSigner(address _address) internal {
    //     if (isOwner(_address) || !isSigner(_address)) return;
    //     for (uint8 i = 0; i < signers.length; i++) {
    //         if (_address == signers[i]) {
    //             // replace the hole with the last element
    //             if (i != i - 1) {
    //                 signers[i] = signers[signers.length - 1];
    //             }
    //             delete signers[signers.length - 1];
    //             signers.length--;
    //             delete signersMapping[_address];

    //             emit SignerRemoved(_address, block.timestamp); // solium-disable-line security/no-block-members
    //             return;
    //         }
    //     }
    // }

    // // Threshold configuration
    // // ===========================================================================

    // function getSignerThreshold() external view returns (uint8) {
    //     return signerThreshold;
    // }

    // function setSignerThreshold(uint8 _signerThreshold) onlyOwner external {
    //     _setSignerThreshold(_signerThreshold);
    // }

    // function setSignerThresholdSigned(uint8 _signerThreshold, bytes sig) external {
    //     bytes32 message = getSetSignerThresholdSignedMessage(_signerThreshold);
    //     require(isOwnerSignature(message, sig));
    //     _setSignerThreshold(_signerThreshold);
    // }

    // function _setSignerThreshold(uint8 _signerThreshold) internal {
    //     signerThreshold = _signerThreshold;
    //     emit SignerThresholdChanged(_signerThreshold, block.timestamp); // solium-disable-line security/no-block-members
    // }

    // function getSetSignerThresholdSignedMessage(uint8 _signerThreshold) public view returns (bytes32) {
    //     return keccak256(byte(0x19), byte(0), this, nonce, "setSignerThreshold", _signerThreshold);
    // }

    // function meetsSignerThreshold(bytes32 _message, bytes _sig) public view returns (bool) {
    //     if (_sig.length == 65) {
    //         return isOwnerSignature(_message, _sig);
    //     }

    //     require(_sig.length % SIGNATURE_LENGTH == 0);

    //     bytes32 hash = ECRecovery.toEthSignedMessageHash(_message);
    //     uint signatureCount = _sig.length / SIGNATURE_LENGTH;

    //     address[] memory signersReceived = new address[](signatureCount);
    //     uint8 uniqueCount;

    //     for (uint i = 0; i < signatureCount; i++) {
    //         address addr = recoverKey(hash, _sig, i);
    //         if (ownersMapping[addr]) {
    //             // if an owner signature is present, accept
    //             return true;
    //         } else if (signersMapping[addr]) {
    //             // only count unique signer signatures
    //             bool found = false;
    //             for (uint8 j = 0; j < uniqueCount; j++) {
    //                 if (addr == signersReceived[j]) {
    //                     found = true;
    //                     break;
    //                 }
    //             }
    //             if (!found) {
    //                 signersReceived[uniqueCount] = addr;
    //                 uniqueCount++;
    //             }
    //         }
    //     }

    //     return uniqueCount >= 1 && uniqueCount >= signerThreshold;
    // }

    // // Execute
    // // ===========================================================================

    // function executeCall(address _to, uint256 _value, bytes _data) external returns (bool) {
    //     require(isOwner(msg.sender) || (isSigner(msg.sender) && signerThreshold <= 1));
    //     return _executeCall(_to, _value, _data);
    // }

    // // TODO: Might be able to process the signatures as a single bytes array if they're a fixed length.
    // function executeCallSigned(address _to, uint256 _value, bytes _data, bytes _sig) external returns (bool) {
    //     require(_to != address(this) && _to != address(0));
    //     bytes32 message = getExecuteCallSignedMessage(_to, _value, _data);
    //     require(meetsSignerThreshold(message, _sig));
    //     return _executeCall(_to, _value, _data);
    // }

    // function _executeCall(address _to, uint256 _value, bytes _data) internal returns (bool success) {
    //     require(_to != address(this) && _to != address(0));

    //     // increment nonce to prevent reentrancy
    //     nonce++;

    //     // solium-disable-next-line security/no-inline-assembly
    //     assembly {
    //         success := call(gas, _to, _value, add(_data, 0x20), mload(_data), 0, 0)
    //     }

    //     emit CallExecuted(_to, _value, _data, block.timestamp); // solium-disable-line security/no-block-members
    // }

    // function getExecuteCallSignedMessage(address _to, uint256 _value, bytes _data) public view returns (bytes32) {
    //     return keccak256(byte(0x19), byte(0), this, nonce, "executeCall", _to, _value, _data);
    // }

    // // TODO: Extract signature utils into npm module.

    // function recoverKey (
    //     bytes32 _hash, 
    //     bytes _sigs,
    //     uint256 _pos
    // ) private pure returns (address) {
    //     uint8 v;
    //     bytes32 r;
    //     bytes32 s;
    //     (v, r, s) = signatureSplit(_sigs, _pos);
    //     return ecrecover(
    //         _hash,
    //         v,
    //         r,
    //         s
    //     );
    // }

    // function signatureSplit(
    //     bytes _signatures,
    //     uint256 _pos
    // ) private pure returns (uint8 v, bytes32 r, bytes32 s) {
    //     uint256 offset = _pos * SIGNATURE_LENGTH;

    //     // solium-disable-next-line security/no-inline-assembly
    //     assembly {
    //         r := mload(add(_signatures, add(32, offset)))
    //         s := mload(add(_signatures, add(64, offset)))
    //         // Here we are loading the last 32 bytes, including 31 bytes
    //         // of 's'. There is no 'mload8' to do this.
    //         //
    //         // 'byte' is not working due to the Solidity parser, so lets
    //         // use the second best option, 'and'
    //         v := and(mload(add(_signatures, add(65, offset))), 0xff)
    //     }

    //     // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    //     if (v < 27) {
    //         v += 27;
    //     }

    //     require(v == 27 || v == 28);
    // }

}
