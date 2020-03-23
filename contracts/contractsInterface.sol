pragma solidity 0.5.16;

contract ContractsInterface {

    mapping (string => address payable) public funOwnership;
    mapping (string => uint) public funPrices;
    mapping (string => bool) public funHidden;

    address payable constant adminAddress = 0xA23E02B08003AD253fa5f217efCBa8D1213c687b;

    function addFunOwnership(string memory fName, address payable developerAddress) public {
        funOwnership[fName] = developerAddress;
    }
    
    function addFunPrice(string memory fName, uint fPrice) public {
        funPrices[fName] = fPrice;
    }

    function addFunHidden(string memory fName, bool h) public {
        funHidden[fName] = h;
    }

    function changeHidden(string memory fName) public {
        funHidden[fName] = !funHidden[fName];
    }

    function removeFunOwnership(string memory fName) public {
        delete funOwnership[fName];
    }

    function removeFunPrices(string memory fName) public {
        delete funPrices[fName];
    }

    function removeFunHidden(string memory fName) public {
        delete funHidden[fName];
    }
}