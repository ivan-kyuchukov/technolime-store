async function main() {
  const TechnoLimeStore = await ethers.getContractFactory("TechnoLimeStore");
  const technoLimeStore = await TechnoLimeStore.deploy();

  await technoLimeStore.deployed();

  console.log("TechnoLimeStore deployed to:", technoLimeStore.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
