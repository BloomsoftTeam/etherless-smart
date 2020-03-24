pragma solidity 0.5.16;

import "etherlessStorage.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";

contract DeployContract is Ownable {

    EtherlessStorage private etherlessStorage;

    event uploadToken(string token, address payable devAddress, string fName, bool updateFun);
    event requestUpload(address payable devAddress);

    function deploy(string memory token, string memory fName) payable public {
        require(msg.value == etherlessStorage.deployFee);
        require(etherlessStorage.hasFunPermission(fName, msg.sender));
        etherlessStorage.setUserOperation.value(msg.value)(msg.sender, "deploy");
        etherlessStorage.addTokenOwnership(token, msg.sender);
        bool updateFun = (etherlessStorage.funOwnership[fName] == msg.sender);
        emit uploadToken(token, msg.sender, fName, updateFun); //ascoltato da EC2
    }
    
    //EC2 chiama
    function sendRequestUpload(address payable devAddress) public onlyOwner{
        emit requestUpload(devAddress);
    }
    
    //EC2 chiama, calcolo del prezzo su server
    function consumeToken(string memory token, string memory fName, address payable devAddress, uint fPrice) public onlyOwner payable returns(bool) {
        if(etherlessStorage.tokenOwnership[token] != 0x0){
            etherlessStorage.removeTokenOwnership(token);
            etherlessStorage.setFun(fName, etherlessStorage.Availability.available, devAddress, fPrice);
            owner().transfer(etherlessStorage.deployFee);
            etherlessStorage.closeOperation(0, deployFee, devAddress, devAddress);
            return true;
        }
        return false;
    }
    
    function requestTokenRefund(string memory token) public payable {
        require(etherlessStorage.tokenOwnership[token] == msg.sender);
        etherlessStorage.closeOperation(deployFee, 0, devAddress, devAddress);
        etherlessStorage.removeTokenOwnership(token);
    }
}