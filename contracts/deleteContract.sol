pragma solidity 0.5.16;

import "./etherlessStorage.sol";

contract DeleteContract {

    EtherlessStorage private etherlessStorage;

    event deleteRequest(string operationHash, string funcName);
    event deleteSuccess(string operationHash);

    function sendDeleteRequest(address devAddress, string memory funcName) public {
        require(etherlessStorage.checkFuncExistance(funcName) && etherlessStorage.hasFuncPermission(funcName, devAddress));
        bytes memory bytesArray = new bytes(32); 
        for (uint256 i; i < 32; i++) { 
          bytesArray[i] = sha256(abi.encodePacked(uint16(msg.sender), "delete", funcName))[i]; 
        }
        string memory operationHash = string(bytesArray);
        etherlessStorage.setUserOperation(msg.sender, operationHash);
        emit deleteRequest(operationHash, funcName);
    }

    function sendDeleteSuccess(string memory operationHash, string memory funcName) public {
        etherlessStorage.removeFuncOwnership(funcName, msg.sender);
        etherlessStorage.closeOperation(operationHash);
        emit deleteSuccess(operationHash);
    }
}