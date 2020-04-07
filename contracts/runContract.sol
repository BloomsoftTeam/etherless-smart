pragma solidity 0.5.16;

import "./etherlessStorage.sol";

contract RunContract is Initializable, Ownable {

    EtherlessStorage private etherlessStorage;

    event runRequest(string operayionHash, string funcName, string funcParameters);
    event runResult(string operationHash, string funcResult);

    function initialize() initializer public {
    
    }

    function sendRunRequest(string memory funcName, string memory funcParameters) public payable returns (string memory) {
        require(etherlessStorage.compareString(etherlessStorage.getFuncAvailability(funcName), "available"));
        require(msg.value == etherlessStorage.getFuncPrice(funcName));
        string memory operationHash = etherlessStorage.getOperationHash(uint16(msg.sender), "run", funcName);
        etherlessStorage.setUserOperation.value(msg.value)(msg.sender, operationHash);
        emit runRequest(operationHash, funcName, funcParameters);
        return operationHash;
    }

    function sendRunResult(string memory funcResult, uint executionPrice, uint devFee, address payable devAddress, string memory operationHash) public onlyOwner {
        etherlessStorage.payCommissions(devAddress, devFee);
        etherlessStorage.payCommissions(msg.sender, executionPrice);
        uint refund = etherlessStorage.getOperationCost(operationHash) - (devFee + executionPrice);
        if (refund > 0) {
          etherlessStorage.closeOperation(operationHash, refund);
        } else {
          etherlessStorage.closeOperation(operationHash);
        }
        emit runResult(operationHash, funcResult);
    }

    function sendRunFailure(string memory funcName, string memory operationHash) public onlyOwner {
      etherlessStorage.setFuncAvailability(funcName, "unavailable");
      etherlessStorage.closeOperation(operationHash, etherlessStorage.getOperationCost(operationHash));
    }

}