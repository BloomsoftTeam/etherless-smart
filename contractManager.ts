import * as fs from 'fs';
import * as path from 'path';
import * as solc from 'solc';
import fetch from 'node-fetch';

export interface CompiledContract {
  interface: string;
  bytecode: string;
}

export function compileContract(contractPath: string): CompiledContract {
  const contractSource: string = fs.readFileSync(contractPath, 'utf-8');
  const contractName: string = path.basename(contractPath, '.sol');
  const contractId = contractName.charAt(0).toUpperCase() + contractName.substring(1);

  const params = {
    language: 'Solidity',
    sources: {
      [contractName]: {
        content: contractSource,
      },
    },
    settings: {
      outputSelection: {
        '*': {
          '*': ['abi', 'evm.bytecode.object'],
        },
      },
    },
  };

  const compiledContracts = JSON.parse(solc.compileStandardWrapper(JSON.stringify(params)));
  const myCompiledContract = compiledContracts.contracts[contractName][contractId];
  return { interface: myCompiledContract.abi, bytecode: myCompiledContract.evm.bytecode.object };
}

export async function getContractInterfaceByAddress(contractAddress: string): Promise<string> {
  try {
    const etherscanUrl = 'https://api-ropsten.etherscan.io/api';
    const query = `?module=contract&action=getabi&address=${contractAddress}&apikey=${process.env.ETHERSCAN_API_KEY}`;
    const response = await fetch(etherscanUrl + query);
    const respJSON = await response.json();
    return respJSON.result;
  } catch (e) {
    console.log(e);
    return e;
  }
}
