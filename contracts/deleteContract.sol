pragma solidity 0.5.16;

import "contractsInterface.sol";

contract DeleteContract is ContractsInterface {

    event deleteRequest(address developerAddress, string fName);
    event deleteSuccess(bool removed);

    function sendDeleteRequest(address developerAddress, string memory fName) public {
        require(funOwnership[fName] == developerAddress);
        emit deleteRequest(developerAddress, fName);
    }

    function sendDeleteSuccess(bool removed, string memory fName) public {
        if(removed) {
            removeFunOwnership(fName);
            removeFunPrices(fName);
            removeFunHidden(fName);
        }
        emit deleteSuccess(removed);
    }
}