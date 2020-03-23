pragma solidity 0.5.16;

import "contractsInterface.sol";

contract RunContract is ContractsInterface {

    address payable private fUser;
    
    constructor() public {
        fUser = msg.sender; // salvo il vez che vuole fare run
    }
    
    modifier onlyUser {
        require(msg.sender == fUser);
        _;
    }

    event runRequest(address payable fUser, string fName, string fParameters);
   
    event runResult(address payable fUser, string fResult);
    
    function deposit() payable public {
        //qua è giusto non scrivere nulla perché si deve settare il value con ethers.js... il msg.value con cui si chiamerà questa funzione sarà anche la cifra depositata
    }

    function withdraw(uint money) public payable {
        require(address(this).balance >= money);
        msg.sender.transfer(money);
    }

    function emitRunEvent(string memory fName, string memory fParameters) public payable onlyUser { 
        deposit();//il vez caccia li sordi sempre definendo il value con ethers
        emit runRequest(msg.sender, fName, fParameters);
    }

    function sendRunResult(string memory fResult, uint moneySpent) public payable {
        withdraw(moneySpent); //il dev si tiene il suo compenso
        RunContract(fUser).withdraw(address(this).balance); //il vez prende il resto
        emit runResult(fUser, fResult); // e vissero tutti felici e contenti
    }
}