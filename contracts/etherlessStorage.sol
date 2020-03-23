pragma solidity 0.5.16;

import "@openzeppelin/contracts/ownership/Ownable.sol";

contract EtherlessStorage is Ownable {

    //Ownable ha automaticamente un campo dati _owner che equivale a chi ha deployato il contratto (di default) e si può trasferire il "possesso" del contratto, fornisce il modifier onlyOwner

    enum Availability{unassigned, available, unavailable}

    mapping (string => address payable) public funOwnership;
    mapping (string => uint) public funPrices;
    mapping (string => Availability) public funAvailability;

    function hasFunPermission(string memory fName, address payable devAddress) public returns(bool){
        return funOwnership[fName] == devAddress || devAddress == _owner;
    }

    function setFunOwnership(string memory fName, address payable devAddress) public returns(bool) {
        if(funOwnership[fName] == 0x0){
            funOwnership[fName] = devAddress;
            return true;
        }
        return hasFunPermission(fName, devAddress);
    }
    
    function setFunPrice(string memory fName, uint fPrice) public onlyOwner {
        funPrices[fName] = fPrice;
    }

    function setFunAvailability(string memory fName, Availability availability) public onlyOwner {
        funAvailability[fName] = availability;
    }

    function setFun(string memory fName, Availability availability, address payable devAddress, uint fPrice) public onlyOwner {
        setFunOwnership(fName, usersAddress);
        setFunAvailability(fName, Availability.available);
        setFunPrice(fName, fPrice);
    }

    function removeFunOwnership(string memory fName, address payable devAddress) public onlyOwner returns(bool) {
        if(hasFunPermission(fName, devAddress)){
            delete funOwnership[fName];
            delete funPrices[fName];
            delete funAvailability[fName];
            return true;
        }
        return false;
    }
}