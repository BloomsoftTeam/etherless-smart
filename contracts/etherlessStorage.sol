pragma solidity 0.5.16;

import "@openzeppelin/contracts/ownership/Ownable.sol";

contract EtherlessStorage is Ownable {

    //Ownable ha automaticamente un campo dati _owner che equivale a chi ha deployato il contratto (di default) e si può trasferire il "possesso" del contratto, fornisce il modifier onlyOwner
    uint constant deployFee = 2000000000000000 wei; //sono circA 20 centesimi

    enum Availability{unassigned, available, unavailable}

    mapping (string => address payable) public funOwnership;
    mapping (string => uint) public funPrices;
    mapping (string => Availability) public funAvailability;
    mapping (string => address payable) public tokenOwnership;
    
    mapping (address => string) public userOperations;

    function hasFunPermission(string memory funName, address payable devAddress) public returns(bool){
        return funOwnership[funName] == devAddress || devAddress == _owner || funOwnership[funName] == 0x0;
    }

    function setFunOwnership(string memory funName, address payable devAddress) public returns(bool) {
        if(funOwnership[funName] == 0x0){
            funOwnership[funName] = devAddress;
            return true;
        }
        return hasFunPermission(funName, devAddress);
    }
    
    function setFunPrice(string memory funName, uint fPrice) public onlyOwner {
        funPrices[funName] = fPrice;
    }

    function setFunAvailability(string memory funName, Availability availability) public onlyOwner {
        funAvailability[funName] = availability;
    }

    function setFun(string memory funName, Availability availability, address payable devAddress, uint fPrice) public onlyOwner {
        setFunOwnership(funName, usersAddress);
        setFunAvailability(funName, Availability.available);
        setFunPrice(funName, fPrice);
    }

    function removeFunOwnership(string memory funName, address payable devAddress) public onlyOwner returns(bool) {
        if(hasFunPermission(funName, devAddress)){
            delete funOwnership[funName];
            delete funPrices[funName];
            delete funAvailability[funName];
            return true;
        }
        return false;
    }

    function checkFunPrice(string memory funName) public view returns (uint) {
      require(funAvailability[funcName] == Availability.available);
      return funcPrices[funcName];
    }

    //Funzioni per la gestione dei token per il deploy

    function addTokenOwnership(string memory token, address payable devAddress) public onlyOwner {
        tokenOwnership[token] = devAddress;
    }

    function removeTokenOwnership(string memory token) public onlyOwner {
        delete tokenOwnership[token];
    }

    //mapping operation
    function setUserOperation(address payable usersAddress, string operation) public onlyOwner {
        userOperations[usersAddress] = operation;
    }

    function removeUserOperation(address payable usersAddress) public onlyOwner {
        delete userOperations[usersAddress];
    }

    //Funzioni di pagamento

    function closeOperation(uint devFee, uint executionPrice, address payable devAddress, address payable userAddress) public onlyOwner{
        if(keccak256(userOperations[userAddress]) == keccak256("deploy")){
            removeUserOperation(userAddress);
            return;
        }
        (msg.sender).transfer(executionPrice);
        (devAddress).transfer(devFee); //il dev si tiene il suo compenso
        uint refund = funPrices[userOperations[userAddress]] - (executionPrice + devFee);        
        (userAddress).transfer(refund); //il vez prende il resto
        removeUserOperation(userAddress);
    }

}