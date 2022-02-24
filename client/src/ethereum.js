import { ethers, Contract } from 'ethers';
import SmartContract from './contracts/TechnoLimeStore.json';

const getBlockchain = () =>
  new Promise((resolve, reject) => {
    window.addEventListener('load', async () => {
      if (window.ethereum) {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();
        const signerAddress = await signer.getAddress();
        const contract = new Contract(
          SmartContract.address,
          SmartContract.abi,
          signer
        );

        resolve({signerAddress, contract, provider});
      }
      resolve({signerAddress: undefined, contract: undefined});
    });
  });

export default getBlockchain;