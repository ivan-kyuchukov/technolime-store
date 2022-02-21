//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract TechnoLimeStore is Ownable {

  struct Product {
    uint id;
    string name;
    uint price;
    uint quantity;
  }
  
  mapping(uint => Product) private products;
  uint[] private productIds;

  uint lastProductId = 1;

  enum ProductAction { Created, Updated }

  event ProductCreateUpdateSuccess(uint productId, uint productAction);
  event ProductOrderMade(uint productId);

  // Admin methods
  // We assume the name will be unique in our store (something like a SKU code)
  function createProduct(string memory _name, uint _price, uint _quantity) public onlyOwner {
    
    require(bytes(_name).length > 0, "Name cannot be empty.");
    require(_price > 0, "Product cannot be free.");
    require(_quantity > 0, "Please provide at least one product quantity.");

    uint productId = productIdByName(_name);

    if (productId > 0) {
      require(_quantity > products[productId].quantity, "You can only increase quantity.");

      products[productId].quantity = _quantity;
      
      emit ProductCreateUpdateSuccess(productId, uint(ProductAction.Updated));
    }
    else {
      productId = lastProductId;
      products[productId].id = productId;
      products[productId].name = _name;
      products[productId].price = _price;
      products[productId].quantity = _quantity;

      productIds.push(productId);
      lastProductId++;

      emit ProductCreateUpdateSuccess(productId, uint(ProductAction.Created));
    }

    // emit StatusChange(productId, products[productId].quantity, uint(products[productId].status));
  }

  // Buyer methods
  function buyProduct(uint _id) public payable {
    Product memory product = products[_id];
    require(product.id > 0, "Product doesn't exist.");
    require(msg.value == product.price, "Please send the exact price amount.");
    require(product.quantity > 0, "Unsufficient product quantity in stock.");

    product.quantity--;
    // TODO: implement contract balance
    // TODO: implement order history

    emit ProductOrderMade(_id);
  }

  // TODO: function handleReturn()

  // function getAllProductIds() external view returns (uint[] memory) {
  //   return productIds;
  // }

  function getAllProducts() external view returns (Product[] memory) {
    Product[] memory productsArray = new Product[](productIds.length);
    for (uint i = 0; i < productIds.length; i++) {
      Product storage product = products[productIds[i]];
      productsArray[i] = product;
    }
    return productsArray;
  }

  function getProductCount() external view returns (uint) {
    return productIds.length;
  }

  function productIdByName(string memory _name) internal view returns (uint) {
    if (productIds.length == 0) {
      return 0;
    }

    for (uint i = 0; i < productIds.length; i++) {
      if (keccak256(abi.encodePacked(products[productIds[i]].name)) == keccak256(abi.encodePacked(_name))) {
        return productIds[i];
      }
    }
    return 0;
  }
}