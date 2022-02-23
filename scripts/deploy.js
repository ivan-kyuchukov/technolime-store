const fs = require('fs');

async function main() {
  const TechnoLimeStore = await ethers.getContractFactory("TechnoLimeStore");
  const technoLimeStore = await TechnoLimeStore.deploy();

  await technoLimeStore.deployed();

  console.log("TechnoLime Store deployed to:", technoLimeStore.address);

  const data = {
    address: technoLimeStore.address,
    abi: JSON.parse(technoLimeStore.interface.format('json'))
  }

  fs.writeFileSync('client/src/contracts/TechnoLimeStore.json', JSON.stringify(data));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
