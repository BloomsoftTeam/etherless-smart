pragma solidity 0.5.16;

import "contractsInterface.sol";

contract RunContract is ContractsInterface {

    address payable private userAddress;
    
    constructor() public {
        userAddress = msg.sender; // salvo il vez che vuole fare run
    }
    
    modifier onlyUser {
        require(msg.sender == userAddress);
        _;
    }

    event runRequest(address payable userAddress, string fName, string fParameters);
   
    event runResult(address payable userAddress, string fResult);
    
    function deposit(string memory fName) payable public onlyUser{
        require(funHidden[fName] == false);
        require(msg.value >= funPrices[fName]);
        //qua è giusto non scrivere nulla perché si deve settare il value con ethers.js... il msg.value con cui si chiamerà questa funzione sarà anche la cifra depositata
    }

    function withdraw(uint money) public payable {
        require(address(this).balance >= money);
        msg.sender.transfer(money);
    }

    function sendRunEvent(string memory fName, string memory fParameters) public payable onlyUser { 
        deposit(fName);//il vez caccia li sordi sempre definendo il value con ethers
        emit runRequest(msg.sender, fName, fParameters);
    }

    function sendRunResult(string memory fResult, uint devFee, uint platformPrice, address payable developerAddress) public payable {
        RunContract(adminAddress).withdraw(platformPrice);
        RunContract(developerAddress).withdraw(devFee); //il dev si tiene il suo compenso
        RunContract(userAddress).withdraw(address(this).balance); //il vez prende il resto
        emit runResult(userAddress, fResult); // e vissero tutti felici e contenti
    }
}