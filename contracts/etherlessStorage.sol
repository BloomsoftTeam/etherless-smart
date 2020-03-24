pragma solidity 0.5.16;

import "@openzeppelin/contracts/ownership/Ownable.sol";

contract EtherlessStorage is Ownable {

    //Ownable ha automaticamente un campo dati _owner che equivale a chi ha deployato il contratto (di default) e si può trasferire il "possesso" del contratto, fornisce il modifier onlyOwner

    enum Availability{unassigned, available, unavailable}

    mapping (string => address payable) public funOwnership;
    mapping (string => uint) public funPrices;
    mapping (string => Availability) public funAvailability;

    function hasFunPermission(string memory funName, address payable devAddress) public returns(bool){
        return funOwnership[funName] == devAddress || devAddress == _owner;
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

    func getFunPrice(string memory funName) public view returns (uint) {
      require(funAvailability[funcName] == Availability.available);
      return funcPrices[funcName];
    }

}