pragma solidity 0.5.16;

import "./etherlessStorage.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract DeployContract is Ownable {

    EtherlessStorage private etherlessStorage;

    event uploadToken(string token, string operationHash, string funcName, bool updateFun);
    event requestUpload(string operationHash);

    function deploy(string memory token, string memory funcName) payable public {
        require(msg.value == etherlessStorage.getDeployFee());
        require(etherlessStorage.hasFuncPermission(funcName, msg.sender));
        bytes32 opBytes = sha256(abi.encodePacked(uint16(msg.sender), "deploy", funcName));
        string memory operationHash = opBytes;
        etherlessStorage.setUserOperation.value(msg.value)(msg.sender, operationHash);
        etherlessStorage.addTokenOwnership(token, msg.sender);
        bool updateFun = (etherlessStorage.getFuncOwnership(funcName) == msg.sender);
        emit uploadToken(token, operationHash, funcName, updateFun); //ascoltato da EC2
    }
    
    //EC2 chiama
    function sendRequestUpload(string memory operationHash) public onlyOwner {
        emit requestUpload(operationHash);
    }
    
    //EC2 chiama, calcolo del prezzo su server
    function consumeToken(string memory token, string memory funcName, address payable devAddress, uint fPrice, string memory operationHash) public onlyOwner payable returns(bool) {
        if(etherlessStorage.getTokenOwnership(token) != address(0)) {
            etherlessStorage.removeTokenOwnership(token);
            etherlessStorage.setFun(funcName, etherlessStorage.Availability.available, devAddress, fPrice);
            etherlessStorage.closeOperation(operationHash);
            return true;
        }
        return false;
    }
    
    function requestTokenRefund(string memory token, string memory operationHash) public payable {
        require(etherlessStorage.getTokenOwnership(token) == msg.sender);
        etherlessStorage.cancelOperation(operationHash);
        etherlessStorage.removeTokenOwnership(token);
        //emit Success
    }
}