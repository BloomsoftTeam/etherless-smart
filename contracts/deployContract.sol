pragma solidity 0.5.16;

import "./etherlessStorage.sol";

contract DeployContract is Initializable, Ownable {

    EtherlessStorage private etherlessStorage;

    event uploadToken(string token, string operationHash, string funcName, bool updateFun);
    event requestUpload(string operationHash);

    function initialize() initializer public {
      
    }

    function deploy(string memory token, string memory funcName) payable public {
        require(msg.value == etherlessStorage.getDeployFee());
        require(etherlessStorage.hasFuncPermission(funcName, msg.sender));

        bytes memory bytesArray = new bytes(32); 
        for (uint256 i; i < 32; i++) { 
          bytesArray[i] = sha256(abi.encodePacked(uint16(msg.sender), "deploy", funcName))[i]; 
        } 
        string memory operationHash = string(bytesArray);
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
            etherlessStorage.setFunc(funcName, "available", devAddress, fPrice);
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