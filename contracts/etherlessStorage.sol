pragma solidity 0.5.16;

import "@openzeppelin/contracts/ownership/Ownable.sol";

contract EtherlessStorage is Ownable {

    //Ownable ha automaticamente un campo dati owner che equivale a chi ha deployato il contratto (di default) e si può trasferire il "possesso" del contratto, fornisce il modifier onlyOwner
    uint constant deployFee = 2000000000000000 wei; //sono circA 20 centesimi

    enum Availability{unassigned, available, unavailable}

    mapping (string => address) private funcOwnership;
    mapping (string => uint) private funcPrices;
    mapping (string => Availability) private funcAvailability;
    mapping (string => address) private tokenOwnership;
    mapping (string => address) private operationUsers;
    mapping (string => uint) private operationCosts;

    function getDeployFee() public returns (uint) {
      return deployFee;
    }

    function hasFuncPermission(string memory funcName, address devAddress) public returns(bool){
        return funcOwnership[funcName] == devAddress || devAddress == owner() || funcOwnership[funcName] == address(0);
    }

    function setfuncOwnership(string memory funcName, address payable devAddress) public returns(bool) {
        if(funcOwnership[funcName] == address(0)){
            funcOwnership[funcName] = devAddress;
            return true;
        }
        return hasFuncPermission(funcName, devAddress);
    }

    function getFuncOwnership(string memory funcName) public returns (address) {
      return funcOwnership[funcName];
    }
    
    function setFuncPrice(string memory funcName, uint fPrice) public onlyOwner {
        funcPrices[funcName] = fPrice;
    }

    function getFuncPrice(string memory funcName) public returns (uint) {
      return funcPrices[funcName];
    }

    function setfuncAvailability(string memory funcName, Availability availability) public onlyOwner {
        funcAvailability[funcName] = availability;
    }

    function getFuncAvailability(string memory funcName) public returns (Availability) {
      return funcAvailability[funcName];
    }

    function setFun(string memory funcName, Availability availability, address payable devAddress, uint fPrice) public onlyOwner {
        setfuncOwnership(funcName, devAddress);
        setfuncAvailability(funcName, Availability.available);
        setFuncPrice(funcName, fPrice);
    }

    function removefuncOwnership(string memory funcName, address payable devAddress) public onlyOwner {
        if(hasFuncPermission(funcName, devAddress)){
            delete funcOwnership[funcName];
            delete funcPrices[funcName];
            delete funcAvailability[funcName];
        }
    }

    function checkFunPrice(string memory funcName) public view returns (uint) {
      require(funcAvailability[funcName] == Availability.available);
      return funcPrices[funcName];
    }

    function checkFuncExistance(string memory funcName) public returns (bool) {
      return funcOwnership[funcName] != address(0);
    }

    //Funzioni per la gestione dei token per il deploy

    function addTokenOwnership(string memory token, address payable devAddress) public onlyOwner {
        tokenOwnership[token] = devAddress;
    }

    function removeTokenOwnership(string memory token) public onlyOwner {
        delete tokenOwnership[token];
    }

    function getTokenOwnership(string memory token) public returns (address) {
      return tokenOwnership[token];
    }

    function setUserOperation(address payable userAddress, string memory operationHash) public onlyOwner payable {
        operationUsers[operationHash] = userAddress;
        operationCosts[operationHash] = msg.value;
    }

    function removeUserOperation(string memory operationHash) public onlyOwner {
        delete operationUsers[operationHash];
        delete operationCosts[operationHash];
    }

    function closeOperation(string memory operationHash, uint refund) public onlyOwner {
      if (refund > 0) {
        (address(uint160(operationUsers[operationHash]))).transfer(refund);
        (address(uint160(owner()))).transfer(getOperationCost(operationHash) - refund);
      } else {
        (address(uint160(owner()))).transfer(getOperationCost(operationHash));
      }
      removeUserOperation(operationHash);
    }

    function closeOperation(string memory operationHash) public onlyOwner {
      (address(uint160(owner()))).transfer(getOperationCost(operationHash));
      removeUserOperation(operationHash);
    }

    function cancelOperation(string memory operationHash) public onlyOwner {
      (address(uint160(getOperationUser(operationHash)))).transfer(getOperationCost(operationHash));
      removeUserOperation(operationHash);
    }

    function payCommissions(address payable receiver, uint amount) public onlyOwner {
      (address(uint160(receiver))).transfer(amount);
    }

    function getOperationUser(string memory operationHash) public returns (address) {
      return operationUsers[operationHash];
    }

    function getOperationCost(string memory operationHash) public returns (uint) {
      return operationCosts[operationHash];
    }

}