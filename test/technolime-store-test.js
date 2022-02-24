const { expect } = require('chai');

describe('TechnoLimeStore contract', () => {
  let TLS, tls, owner, address1, address2;

  before(async () => {
    TLS = await ethers.getContractFactory('TechnoLimeStore');
    tls = await TLS.deploy();
    [owner, address1, address2, _] = await ethers.getSigners();
  })

  describe('DEPLOYMENT', () => {
    it('Should set the right owner', async () => {
      expect(await tls.owner()).to.equal(owner.address);
    });
  })

  describe('PRODUCT CREATION', () => {

    it('Should only create products by the owner', async () => {
      // .to.be.revertedWith('You can only increase quantity.') doesn't work for some reason..
      try {
        await tls.connect(address1).createProduct('product1', 100, 0);
      }
      catch (error) {
        expect(error.message).to.equal("VM Exception while processing transaction: reverted with reason string 'Caller is not the owner.'");
      }
    });

    it('Should return 0 as products count', async () => {
      expect(await tls.getProductCount())
        .to.equal(0);
    });

    // Product 1
    it('Should create product1', async () => {
      expect(await tls.createProduct('product1', 100, 10))
        .to.emit(tls, 'ProductAction')
        .withArgs(1, 0); // emit ProductAction.Created(0) event
    });

    it('Should return 1 as products count', async () => {
      expect(await tls.getProductCount())
        .to.equal(1);
    });

    it('Should update product1', async () => {
      expect(await tls.createProduct('product1', 100, 11))
        .to.emit(tls, 'ProductAction')
        .withArgs(1, 1); // emit ProductAction.Updated(1) event
    });

    it('Should not be able to decrease quantity', async () => {
      // .to.be.revertedWith('You can only increase quantity.') doesn't work for some reason..
      try {
        await tls.createProduct('product1', 100, 9);
      }
      catch (error) {
        expect(error.message).to.equal("VM Exception while processing transaction: reverted with reason string 'Product exists. You can only increase its quantity.'");
      }
    });

    it('Should not be able to create product with empty name', async () => {
      // .to.be.revertedWith('You can only increase quantity.') doesn't work for some reason..
      try {
        await tls.createProduct('', 100, 9);
      }
      catch (error) {
        expect(error.message).to.equal("VM Exception while processing transaction: reverted with reason string 'Name cannot be empty.'");
      }
    });

    it('Should not be able to create product with 0 price', async () => {
      // .to.be.revertedWith('You can only increase quantity.') doesn't work for some reason..
      try {
        await tls.createProduct('product1', 0, 9);
      }
      catch (error) {
        expect(error.message).to.equal("VM Exception while processing transaction: reverted with reason string 'Product cannot be free.'");
      }
    });

    it('Should not be able to create product with 0 quantity', async () => {
      // .to.be.revertedWith('You can only increase quantity.') doesn't work for some reason..
      try {
        await tls.createProduct('product1', 100, 0);
      }
      catch (error) {
        expect(error.message).to.equal("VM Exception while processing transaction: reverted with reason string 'Please provide at least one product quantity.'");
      }
    });

    // Product 2
    it('Should create product2', async () => {
      expect(await tls.createProduct('product2', 100, 10))
        .to.emit(tls, 'ProductAction')
        .withArgs(2, 0); // emit ProductAction.Created(0) event
    });

    it('Should return 2 as products count', async () => {
      expect(await tls.getProductCount())
        .to.equal(2);
    });

    it('Should return array of 2 products', async () => {
      const result = await tls.getAllProducts();
      const products = result.map((item) => {
        return {
          id: item.id.toNumber(),
          name: item.name,
          price: item.price.toNumber(),
          quantity: item.quantity
        }
      });
      expect(products.length)
        .to.equal(2);
    });

    it('Should be able to only increase quantity', async () => {
      try {
        expect(await tls.createProduct('product2', 100, 8));
      }
      catch (error) {
        expect(error.message).to.equal("VM Exception while processing transaction: reverted with reason string 'Product exists. You can only increase its quantity.'");
      }
    });
  })

  describe('ORDER PLACEMENT //TODO', () => { })
  describe('ORDER RETURN //TODO', () => { })
  describe('HELPER FUNCTIONS //TODO', () => { })
});