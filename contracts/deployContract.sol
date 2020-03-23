pragma solidity 0.5.16;

import "contractsInterface.sol";
//Ownable = openzeppelin
contract DeployContract is ContractsInterface {
    uint constant costoDeploy = 1759633996128805 wei; //sono 20 centesimi
    
    mapping (string => address payable) tokenOwnership;

    event uploadToken(string token, address payable userAddress, string fName);
    event requestUpload(address payable userAddress);

    function addTokenOwnership(string memory token, address payable developerAddress) public {
        tokenOwnership[token] = developerAddress;
    }

    function removeTokenOwnership(string memory token) public {
        delete tokenOwnership[token];
    }

    function deploy(string memory token, string memory fName) payable public {
        require(msg.sender.balance >= costoDeploy);
        msg.sender.transfer(costoDeploy);
        addTokenOwnership(token, msg.sender);
        emit uploadToken(token, msg.sender, fName); //ascoltato da EC2
    }
    
    //EC2 chiama
    function sendRequestUpload(address payable userAddress) public {
        emit requestUpload(userAddress);
    }
    
    //EC2 chiama, calcolo del prezzo su server
    function consumeToken(string memory token, string memory fName, address payable userAddress, uint fPrice) public {
        removeTokenOwnership(token);
        addFunOwnership(fName, userAddress);
        addFunHidden(fName, false);
        addFunPrice(fName, fPrice);
    }
    
    function requestTokenRefund(string memory token) public {
        require(tokenOwnership[token] == msg.sender);
        msg.sender.transfer(costoDeploy);
        removeTokenOwnership(token);
    }
}