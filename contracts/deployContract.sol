pragma solidity 0.5.16;

import "contractsInterface.sol";
//Ownable = openzeppelin
contract DeployContract is Ownable, ContractsInterface {
    const uint costoDeploy = 1759633996128805 wei; //sono 20 centesimi
    
    mapping (string memory => address payable) tokenOwnership;

    event uploadToken(string memory token, address payable userAddress, string memory fName);
    event requestUpload(address payble userAddress);

    function addTokenOwnership(string memory token, address payable developerAddress) public {
        tokenOwnership[token] = developerAddress;
    }

    function removeTokenOwnership(string memory token) public {
        delete tokenOwnership[token];
    }

    function deploy(string memory token, string memory fName) payable {
        require(msg.sender.balance >= costoDeploy);
        msg.sender.transfer(costoDeploy);
        addTokenOwnership(token, msg.sender);
        emit event uploadToken(token, msg.sender, fName); //ascoltato da EC2
    }
    
    //EC2 chiama
    function sendRequestUpload(address payable userAddress) {
        emit event requestUpload(userAddress);
    }
    
    //EC2 chiama, calcolo del prezzo su server
    function consumeToken(string memory token, string memory fName, address payable userAddress, uint fPrice) {
        removeTokenOwnership(token);
        addFunOwnership(fName, userAddress);
        addFunHidden(fName, false);
        addFunPrice(fName, fPrice);
    }
    
    function requestTokenRefund(string memory token) {
        require(tokenOwnership[token] == msg.sender);
        msg.sender.transfer(costoDeploy);
        removeTokenOwnership(token);
    }
