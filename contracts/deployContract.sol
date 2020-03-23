pragma solidity 0.5.16;

contract DeployContract is Ownable {
    // costoDeploy = 20cent;

    func deploy(token: string memory) payable {
        check msg.value == DEPLOY_FEE
        tokenOwnership[msg.sender] = token;
        emit event UploadToken(token, msg.sender) //ascoltato da EC2
    }
    
    //EC2 chiama
    func requestUpload(userAddress) {
        emit event RequestUpload(userAddress);
    }
    
    //EC2 chiama
    func consumeToken(token) {
        delete tokenOwnership[token];
        mapping funcOwnership[funcName] = userAddress;
        mapping available hidden false
        mapping funcPrice = totalPrice
    }
    
    func requestTokenRefund(token) {
        check mapping tokenOwnership (msg.sender possegga quel token)
        msg.sender.transfer(DEPLOYFEE);
        delete tokenOwnership[];
        //eliminare da cli il token
    }
