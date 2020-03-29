pragma solidity 0.5.16;

import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";

contract EtherlessStorage is Initializable, Ownable {

    //Ownable ha automaticamente un campo dati owner che equivale a chi ha deployato il contratto (di default) e si può trasferire il "possesso" del contratto, fornisce il modifier onlyOwner
    uint constant deployFee = 2000000000000000 wei; //sono circA 20 centesimi

    enum Availability{unassigned, available, unavailable}

    mapping (string => address) private funcOwnership;
    mapping (string => uint) private funcPrices;
    mapping (string => Availability) private funcAvailability;
    mapping (string => address) private tokenOwnership;
    mapping (string => address) private operationUsers;
    mapping (string => uint) private operationCosts;

    function initialize() initializer public {
    
    }

    function compareString(string memory first, string memory second) public pure returns (bool) {
      return (keccak256(abi.encodePacked(first)) == keccak256(abi.encodePacked(second)));
    }

    function getAvailabilityFromString(string memory availability) private pure returns (Availability) {
      if (compareString(availability, "available")) {
        return Availability.available;
      } else if (compareString(availability, "unavailable")) {
        return Availability.unavailable;
      }
      return Availability.unassigned;
    }

    function getStringFromAvailability(Availability availability) private pure returns (string memory) {
      if (Availability.available == availability) {
        return "available";
      } else if (Availability.unavailable == availability) {
        return "unavailable";
      }
      return "unassigned";
    }

    function getDeployFee() public pure returns (uint) {
      return deployFee;
    }

    function hasFuncPermission(string memory funcName, address devAddress) public view returns(bool){
        return funcOwnership[funcName] == devAddress || devAddress == owner() || funcOwnership[funcName] == address(0);
    }

    function setFuncOwnership(string memory funcName, address devAddress) public returns(bool) {
        if(funcOwnership[funcName] == address(0)){
            funcOwnership[funcName] = devAddress;
            return true;
        }
        return hasFuncPermission(funcName, devAddress);
    }

    function getFuncOwnership(string memory funcName) public view returns (address) {
      return funcOwnership[funcName];
    }
    
    function setFuncPrice(string memory funcName, uint fPrice) public onlyOwner {
        funcPrices[funcName] = fPrice;
    }

    function getFuncPrice(string memory funcName) public view returns (uint) {
      return funcPrices[funcName];
    }

    function setFuncAvailability(string memory funcName, string memory availability) public onlyOwner {
        funcAvailability[funcName] = getAvailabilityFromString(availability);
    }

    function getFuncAvailability(string memory funcName) public view returns (string memory) {
      return getStringFromAvailability(funcAvailability[funcName]);
    }

    function setFunc(string memory funcName, string memory availability, address devAddress, uint funcPrice) public onlyOwner {
        setFuncOwnership(funcName, devAddress);
        setFuncAvailability(funcName, availability);
        setFuncPrice(funcName, funcPrice);
    }

    function removeFuncOwnership(string memory funcName, address devAddress) public onlyOwner {
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

    function checkFuncExistance(string memory funcName) public view returns (bool) {
      return funcOwnership[funcName] != address(0);
    }

    //Funzioni per la gestione dei token per il deploy

    function addTokenOwnership(string memory token, address devAddress) public onlyOwner {
        tokenOwnership[token] = devAddress;
    }

    function removeTokenOwnership(string memory token) public onlyOwner {
        delete tokenOwnership[token];
    }

    function getTokenOwnership(string memory token) public view returns (address) {
      return tokenOwnership[token];
    }

    function setUserOperation(address userAddress, string memory operationHash) public onlyOwner payable {
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

    function payCommissions(address receiver, uint amount) public onlyOwner {
      (address(uint160(receiver))).transfer(amount);
    }

    function getOperationUser(string memory operationHash) public view returns (address) {
      return operationUsers[operationHash];
    }

    function getOperationCost(string memory operationHash) public view returns (uint) {
      return operationCosts[operationHash];
    }

}