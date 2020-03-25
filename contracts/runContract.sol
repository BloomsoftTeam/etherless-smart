pragma solidity 0.5.16;

import "etherlessStorage.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract RunContract is Ownable {

    EtherlessStorage private etherlessStorage;

    event runRequest(string operayionHash, string funcName, string funcParameters);
    event runResult(string operationHash, string funcResult);

    function sendRunRequest(string memory funcName, string memory funcParameters) public payable {
        require(etherlessStorage.getFuncAvailability(funcName) == etherlessStorage.Availability.available);
        require(msg.value == etherlessStorage.getFuncPrice(funcName));
        string memory operationHash = sha256(abi.encodePacked(uint16(msg.sender), "run", funcName));
        etherlessStorage.setUserOperation.value(msg.value)(msg.sender, operationHash);
        emit runRequest(operationHash, funcName, funcParameters);
    }

    function sendRunResult(string memory funcResult, uint executionPrice, uint devFee, address payable devAddress, string memory operationHash) public onlyOwner {
        etherlessStorage.payCommissions(devAddress, devFee);
        etherlessStorage.payCommissions(msg.sender, executionPrice);
        uint refund = etherlessStorage.getoperationCost(operationHash) - (devFee + executionPrice);
        if (refund > 0) {
          etherlessStorage.closeoperation(operationHash, refund);
        } else {
          etherlessStorage.closeoperation(operationHash);
        }
        emit runResult(operationHash, funcResult);
    }

    function sendRunFailure(string memory funcName, string memory operationHash) public onlyOwner {
      etherlessStorage.setFuncAvailability(funcName, etherlessStorage.Availability.unavailable);
      etherlessStorage.closeOperation(operationHash, etherlessStorage.getOperationCost(operationHash));
    }

}