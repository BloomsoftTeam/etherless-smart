pragma solidity 0.5.16;

import "contractsInterface.sol";
//Ownable = openzeppelin
contract DeployContract is ContractsInterface {
    uint constant deployFee = 1759633996128805 wei; //sono 20 centesimi
    
    mapping (string => address payable) tokenOwnership;

    event uploadToken(string token, address payable devAddress, string fName, bool updateFun);
    event requestUpload(address payable devAddress);

    function addTokenOwnership(string memory token, address payable devAddress) public {
        tokenOwnership[token] = devAddress;
    }

    function removeTokenOwnership(string memory token) private {
        delete tokenOwnership[token];
    }

    function deploy(string memory token, string memory fName) payable public {
        require(msg.sender.balance >= deployFee);
        bool updateFun = (funOwnership[fName] == msg.sender);
        addTokenOwnership(token, msg.sender);
        emit uploadToken(token, msg.sender, fName, updateFun); //ascoltato da EC2
    }
    
    //EC2 chiama
    function sendRequestUpload(address payable devAddress) public onlyOwner{
        emit requestUpload(devAddress);
    }
    
    //EC2 chiama, calcolo del prezzo su server
    function consumeToken(string memory token, string memory fName, address payable devAddress, uint fPrice) public onlyOwner payable returns(bool) {
        if(tokenOwnership[token] != 0x0){
            removeTokenOwnership(token);
            setFunOwnership(fName, usersAddress);
            setFunAvailability(fName, true);
            setFunPrice(fName, fPrice);
            owner().transfer(deployFee);
            return true;
        }
        return false;
    }
    
    function requestTokenRefund(string memory token) public payable {
        require(tokenOwnership[token] == msg.sender);
        msg.sender.transfer(deployFee);
        removeTokenOwnership(token);
    }
}