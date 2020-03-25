pragma solidity 0.5.16;

import "@openzeppelin/contracts/ownership/Ownable.sol";

contract EtherlessStorage is Ownable {

    //Ownable ha automaticamente un campo dati _owner che equivale a chi ha deployato il contratto (di default) e si può trasferire il "possesso" del contratto, fornisce il modifier onlyOwner
    uint constant deployFee = 2000000000000000 wei; //sono circA 20 centesimi

    enum Availability{unassigned, available, unavailable}

    mapping (string => address) private funcOwnership;
    mapping (string => uint) private funcPrices;
    mapping (string => Availability) private funcAvailability;
    mapping (string => address) private tokenOwnership;
    mapping (string => address) private operationHashUsers;
    mapping (string => uint) private operationHashCosts;

    function hasFuncPermission(string memory funcName, address payable devAddress) public returns(bool){
        return funcOwnership[funcName] == devAddress || devAddress == _owner || funcOwnership[funcName] == 0x0;
    }

    function setfuncOwnership(string memory funcName, address payable devAddress) public returns(bool) {
        if(funcOwnership[funcName] == 0x0){
            funcOwnership[funcName] = devAddress;
            return true;
        }
        return hasFuncPermission(funcName, devAddress);
    }

    function getFuncOwnership(string memory funcName) returns (address) {
      return funcOwnership[funcName];
    }
    
    function setFuncPrice(string memory funcName, uint fPrice) public onlyOwner {
        funcPrices[funcName] = fPrice;
    }

    function getFuncPrice(string memory funcName) returns (uint) {
      return funcPrices[funcName];
    }

    function setfuncAvailability(string memory funcName, Availability availability) public onlyOwner {
        funcAvailability[funcName] = availability;
    }

    function getFuncAvailability(string memory funcName) returns (Availability) {
      return funcAvailability[funcName];
    }

    function setFun(string memory funcName, Availability availability, address payable devAddress, uint fPrice) public onlyOwner {
        setfuncOwnership(funcName, usersAddress);
        setfuncAvailability(funcName, Availability.available);
        setFunPrice(funcName, fPrice);
    }

    function removefuncOwnership(string memory funcName, address payable devAddress) public onlyOwner {
        if(hasFunPermission(funcName, devAddress)){
            delete funcOwnership[funcName];
            delete funcPrices[funcName];
            delete funcAvailability[funcName];
        }
    }

    function checkFunPrice(string memory funcName) public view returns (uint) {
      require(funcAvailability[funcName] == Availability.available);
      return funcPrices[funcName];
    }

    function checkFuncExistance(string memory funcName) returns (bool) {
      return funcOwnership[funcName] != 0x0;
    }

    //Funzioni per la gestione dei token per il deploy

    function addTokenOwnership(string memory token, address payable devAddress) public onlyOwner {
        tokenOwnership[token] = devAddress;
    }

    function removeTokenOwnership(string memory token) public onlyOwner {
        delete tokenOwnership[token];
    }

    function getTokenOwnership(string memory token) returns (address) {
      return tokenOwnership[token];
    }

    function setUserOperation(address payable userAddress, string memory operationHash) public onlyOwner payable {
        operationHashUsers[operationHash] = userAddress;
        operationHashCosts[operationHash] = msg.value;
    }

    function removeUserOperation(string memory operationHash) public onlyOwner {
        delete operationHashUsers[operationHash];
        delete operationHashCosts[operationHash];
    }

    function closeOperation(string memory operationHash, uint refund) public onlyOwner {
      if (refund > 0) {
        (operationHashUsers[operationHash]).transfer(refund);
        (_owner).transfer(getoperationCost(operationCost) - refund);
      } else {
        (_owner).transfer(getoperationCost(operationCost));
      }
      removeUserOperation(operationHash);
    }

    function closeOperation(string memory operationHash) public onlyOwner {
      (_owner).transfer(getoperationCost(operationCost));
      removeUserOperation(operationHash);
    }

    function cancelOperation(string memory operationHash) public onlyOwner {
      (getOperationOwnership(operationHash)).transfer(getoperationCost(operationHash));
      removeUserOperation(operationHash);
    }

    function payCommissions(address payable receiver, uint amount) public onlyOwner {
      (receiver).transfer(amout);
    }

    function getOperationOwnership(string memory operationHash) returns (address) {
      return operationHashOwnership[operationHash];
    }

    function getOperationCost(string memory operationHash) returns (uint) {
      return operationHashCosts[operationHash];
    }

}