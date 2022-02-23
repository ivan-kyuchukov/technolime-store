import { ethers, utils, Contract } from 'ethers';
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

        // const filter = {
        //   address: SmartContract.address,
        //   topics: [
        //     utils.id("OrderAction(uint256,uint256,address,uint8)")
        //   ]
        // }
        // provider.on(filter, (data) => {
        //   console.log(data)
        //     // do whatever you want here
        //     // I'm pretty sure this returns a promise, so don't forget to resolve it
        // })

        resolve({signerAddress, contract, provider});
      }
      resolve({signerAddress: undefined, contract: undefined});
    });
  });

export default getBlockchain;