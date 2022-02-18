const { expect } = require('chai');

describe('TechnoLimeStore contract', () => {
  let TechnoLimeStore, technoLimeStore, owner, address1, address2;

  beforeEach(async () => {
    TechnoLimeStore = await ethers.getContractFactory('TechnoLimeStore');
    technoLimeStore = await TechnoLimeStore.deploy();
    [owner, address1, address2, _] = await ethers.getSigners();
  })

  describe('Deployment', () => {
    it('Should set the right owner', async () => {
      expect(await technoLimeStore.owner()).to.equal(owner.address);
    });

  })

});
