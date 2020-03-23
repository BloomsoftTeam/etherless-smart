pragma solidity 0.5.16;

import "etherlessStorage.sol";

contract DeleteContract {

    EtherlessStorage private etherlessStorage;

    event deleteRequest(address devAddress, string funName);
    event deleteSuccess(bool removed);

    function sendDeleteRequest(address devAddress, string memory funName) public {
        require(etherlessStorage.hasFunPermission(funName, devAddress));
        emit deleteRequest(devAddress, funName);
    }

    function sendDeleteSuccess(bool removed, string memory funName) public {
        bool deleteResult = etherlessStorage.removeFunOwnership(funName, msg.sender);
        emit deleteSuccess(deleteResult);
    }
}