pragma solidity 0.5.16;

import "./etherlessStorage.sol";

contract DeleteContract is Initializable {

    EtherlessStorage private etherlessStorage;

    event deleteRequest(string operationHash, string funcName);
    event deleteSuccess(string operationHash);

    function initialize() initializer public {
    
    }

    function sendDeleteRequest(string memory funcName) public {
        require(etherlessStorage.checkFuncExistance(funcName) && etherlessStorage.hasFuncPermission(funcName, msg.sender));
        string memory operationHash = etherlessStorage.getOperationHash(uint16(msg.sender), "delete", funcName);
        etherlessStorage.setUserOperation(msg.sender, operationHash);
        emit deleteRequest(operationHash, funcName);
    }

    function sendDeleteSuccess(string memory operationHash, string memory funcName) public {
        etherlessStorage.removeFuncOwnership(funcName, msg.sender);
        etherlessStorage.closeOperation(operationHash);
        emit deleteSuccess(operationHash);
    }
}