pragma solidity 0.5.16;

import "etherlessStorage.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract RunContract is Ownable {

    EtherlessStorage private etherlessStorage;

    event runRequest(address payable userAddress, string fName, string fParameters);
   
    event runResult(address payable userAddress, string fResult);

    function sendRunRequest(string memory fName, string memory fParameters) public payable {
        require(etherlessStorage.funAvailability[fName] == etherlessStorage.Availability.available);
        require(msg.value == etherlessStorage.funPrices[fName]);  
        etherlessStorage.setUserOperation.value(msg.value)(msg.sender, fName);
        emit runRequest(msg.sender, fName, fParameters);
    }

    function sendRunResult(string memory fResult, uint devFee, uint executionPrice, address payable devAddress, address payable userAddress) public onlyOwner {
        etherlessStorage.removeUserOperation(userAddress);
        emit runResult(userAddress, fResult); // e vissero tutti felici e contenti
    }
}