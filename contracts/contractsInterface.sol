pragma solidity 0.5.16;

contract ContractsInterface {

    mapping (string => address payable) public devFun;
    mapping (string => uint) public funPrices;
    mapping (string => bool) public funHidden;

    function addDevFun(string memory fName, address payable fDeveloper) public {
        devFun[fName] = fDeveloper;
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
}