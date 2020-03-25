pragma solidity 0.5.16;

import "etherlessStorage.sol";

contract DeleteContract {

    EtherlessStorage private etherlessStorage;

    event deleteRequest(string operationHash, string funcName);
    event deleteSuccess(string operationHash);

    function sendDeleteRequest(address devAddress, string memory funcName) public {
        require(etherlessStorage.checkFuncExistance(funcName) && etherlessStorage.hasFunPermission(funcName, devAddress));
        string memory operationHash = sha256(abi.encodePacked(uint16(msg.sender), "delete", funcName));
        etherlessStorage.setUserOperation(msg.sender, operationHash);
        emit deleteRequest(operationHash, funcName);
    }

    function sendDeleteSuccess(string memory operationHash, string memory funcName) public {
        etherlessStorage.removefuncOwnership(funcName, msg.sender);
        etherlessStorage.closeOperation(operationHash);
        emit deleteSuccess(operationHash);
    }
}