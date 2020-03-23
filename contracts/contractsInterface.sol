pragma solidity 0.5.16;

import "@openzeppelin/contracts/ownership/Ownable.sol";

contract ContractsInterface is Ownable {

    //Ownable ha automaticamente un campo dati _owner che equivale a chi ha deployato il contratto (di default) e si può trasferire il "possesso" del contratto, fornisce il modifier onlyOwner

    mapping (string => address payable) public funOwnership;
    mapping (string => uint) public funPrices;
    mapping (string => bool) public funAvailability;

    function hasFunPermission(string memory fName, address payable devAddress) public returns(bool){
        return funOwnership[fName] == devAddress;
    }

    function setFunOwnership(string memory fName, address payable devAddress) public returns(bool) {
        if(funOwnership[fName] == 0){
            funOwnership[fName] = devAddress;
            return true;
        }
        return funOwnership[fName] == devAddress;
    }
    
    function setFunPrice(string memory fName, uint fPrice) public onlyOwner {
        funPrices[fName] = fPrice;
    }

    function setFunAvailability(string memory fName, bool available) public onlyOwner {
        funAvailability[fName] = available;
    }

    function removeFunOwnership(string memory fName, address payable devAddress) public returns(bool) {
        if(hasFunPermission(fName, devAddress)){
            delete funOwnership[fName];
            delete funPrices[fName];
            delete funAvailability[fName];
            return true;
        }
        return false;
    }
}