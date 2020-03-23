pragma solidity 0.5.16;

import "contractsInterface.sol";

contract DeleteContract is ContractInterface {

    event deleteRequest(address developerAddress, string memory fName);
    event deleteSuccess(bool removed);

    function sendDeleteRequest(address developerAddress, string memory fName) {
        require(funcOwnership[fName] == developerAddress);
        emit deleteRequest(developerAddress, fName);
    }

    function sendDeleteSuccess(bool removed, string memory fName) {
        if(removed) {
            removeFunOwnership(fName);
            removeFunPrices(fName);
            removeFunHidden(fName);
        }
        emit deleteSuccess(removed);
    }
}