import * as path from 'path';
import * as fs from 'fs';

import { ethers } from 'ethers';
import { Contract } from 'ethers/contract';
import { Wallet } from 'ethers/wallet';
import { InfuraProvider } from 'ethers/providers';
import * as contractManager from './contractManager';
import { KeyManager } from './keyManager';

import dotenv = require('dotenv');

dotenv.config();

export class EthersManager {
  readonly provider: InfuraProvider;

  readonly keyManager: KeyManager;

  userWallet: Wallet;

  constructor(keyManager: KeyManager) {
    this.provider = new ethers.providers.InfuraProvider('ropsten', process.env.INFURA_PROJECT_ID);
    this.keyManager = keyManager;
  }

  static newWallet(): Wallet {
    const bytes = ethers.utils.randomBytes(16);
    const randomMnemonic = ethers.utils.HDNode.entropyToMnemonic(bytes, ethers.wordlists.en);
    const myWallet = ethers.Wallet.fromMnemonic(randomMnemonic);
    return myWallet;
  }

  getWalletFromPrivate(privateKey: string): Wallet | null {
    try {
      const myWallet = new ethers.Wallet(privateKey, this.provider);
      return myWallet;
    } catch (e) {
      console.error(e);
      return null;
    }
  }

  // Quando chiamate, questo metodo ritornerà una promise e dovete settare per forza un catch block
  async loadSmartContract(contractAddress: string): Promise<Contract> {
    const contractInterface = await contractManager.getContractInterfaceByAddress(contractAddress);
    const contract = new ethers.Contract(contractAddress, contractInterface, this.provider);
    return contract;
  }

  saveEthWalletCredentials(wallet: Wallet) {
    this.keyManager.saveCredentials(wallet.privateKey);
    const credentialsPath = path.resolve(__dirname, '.credentials');
    const walletPath = path.resolve(credentialsPath, 'wallet.txt');
    fs.writeFileSync(walletPath, `Wallet address: ${wallet.address} '\nPrivate Key: ${wallet.privateKey}`);
  }

  /* -------------------------------------------------------------------------------------------- */

  checkEthWalletExistance() {
    return fs.existsSync(this.keyManager.privatePath);
  }

  createNewEthWallet(): Wallet {
    const myNewWallet = EthersManager.newWallet();
    this.userWallet = myNewWallet;
    this.saveEthWalletCredentials(myNewWallet);
    return myNewWallet;
  }

  linkEthWallet(privateKey: string): boolean {
    const walletFromPrivate = this.getWalletFromPrivate(privateKey);
    if (walletFromPrivate == null) {
      return false;
    }
    this.userWallet = walletFromPrivate;
    this.saveEthWalletCredentials(walletFromPrivate);
    return true;
  }

  loadWalletFromFS() {
    return new Promise((resolve, reject) => {
      try {
        if (fs.existsSync(this.keyManager.privatePath)) {
          this.keyManager.decryptKey().then((privateKey: string) => {
            try {
              if (this.linkEthWallet(privateKey)) {
                resolve(true);
              } else {
                reject(new Error('an ETH wallet associated with the specified private key was not found'));
              }
            } catch (e) {
              console.error(e);
              reject(e);
            }
          });
        } else {
          reject(new Error('no credentials were founds on the file system'));
        }
      } catch (err) {
        console.error(err);
        reject(new Error('no credentials were founds on the file system'));
      }
    });
  }

  removeWalletFromFS(): boolean {
    const removeKey = this.keyManager.removeCredentials();
    const credentialsPath = path.resolve(__dirname, '.credentials');
    const walletPath = path.resolve(credentialsPath, 'wallet.txt');
    try {
      fs.unlinkSync(walletPath);
      return true && removeKey;
    } catch (err) {
      return false;
    }
  }

  async deploySmartContract(contractPath: string) {
    const deployContract = async () => {
      const myCompiled = contractManager.compileContract(contractPath);
      const factory = new ethers.ContractFactory(myCompiled.interface, myCompiled.bytecode)
        .connect(this.userWallet);
      const myContract = await factory.deploy();
      console.log(`contract address being deployed: ${myContract.address}`);
      await myContract.deployed().then((contract) => { console.log(`contract UPLOADED: ${contract.address}`); });
    };

    await deployContract()
      .catch((e) => { console.log(e); });
  }

  deployFunc(funcName: string) {
    this.loadSmartContract('0x59Acf9e0e4fAdE6b845810d02C27e6eFEfDd7eA4')
    .then((deployContract) => {
      const deployContractSigned = deployContract.connect(this.userWallet);
      deployContractSigned.deployFunc(funcName, { value: 10**15, }).then(console.log);

      deployContractSigned.on('DeployFailureEvent', (response) => {
        console.log('Ricevuto risultato: ');
        console.log(response);
        deployContractSigned.removeAllListeners('DeployFailureEvent');
        deployContractSigned.removeAllListeners('DeploySuccessEvent');
      });

      deployContractSigned.on('DeploySuccessEvent', (response) => {
        console.log('Ricevuto risultato: ');
        console.log(response);
        deployContractSigned.removeAllListeners('DeploySuccessEvent');
        deployContractSigned.removeAllListeners('DeployFailureEvent');
      });
    })
    .catch(console.log);
  }

  showPrivateKey() {
    this.keyManager.decryptKey().then(console.log).catch(console.log);
  }
}
