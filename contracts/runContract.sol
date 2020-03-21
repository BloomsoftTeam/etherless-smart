pragma solidity ^0.5.16;

contract RunContract {

    // address payable ownerAddress;
    // uint basePrice;
    mapping (string => address payable) private devFun;
    mapping (string => uint) private funPrices;

    event runRequest(address payable fUser, string fName, string fParameters, address payable fDeveloper);
    //Se teniamo la funzione di somma, usiamo uint per mettergli i risultati
    event runResult(address payable rReceiver, string fResult); //, uint remainingEthers);
    
    function addDevFun(string memory fName, address payable fDeveloper) public {
        devFun[fName] = fDeveloper;
    }
    
    function addFunPrice(string memory fName, uint fPrice) public {
        funPrices[fName] = fPrice;
    }
    
    
    function getString() public pure returns(string memory) {
        return "Hello";
    }

    function sendRunEvent(string memory fName, string memory fParameters) public payable { 
        //Richiesta minima di basePrice sul wallet per eseguire l'operazione
        // require(ownerAddress.balance >= basePrice);
        //Trasferisce al contratto gli eth di basePrice dal wallet
        // ownerAddress.transfer(basePrice);
        //A questo punto si può procedere con la richiesta del run
        address payable dev = devFun[fName];
        require(msg.value >= funPrices[fName], "Enough ethereum to proceed");
        dev.transfer(funPrices[fName]);
        emit runRequest(msg.sender, fName, fParameters, dev);
    }

    function sendRunResult(address payable rReceiver, string memory fResult, uint moneyLeft) public payable {
        //Calcola il resto
        // uint remainingEthers = basePrice - runCost;
        //Riassegna il resto al wallet che ha inviato la richiesta

        //TO DO
        //Pezzo mancante...restituire i soldi da contract a wallet (dovrebbe essere una riga)
        

        //Manda l'evento alla cli con risultato e resto di cui fare il console log
        rReceiver.transfer(moneyLeft);
        emit runResult(rReceiver, fResult); //, remainingEthers);
    }
}