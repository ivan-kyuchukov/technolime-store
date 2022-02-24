//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Ownable.sol";

contract TechnoLimeStore is Ownable {

  struct Product {
    uint id;
    string name;
    uint price;
    uint8 quantity;
  }

  struct Order {
    uint productId;
    uint8 productQuantity;
    address buyerAddress;
    uint createdAtBlock;
  }
  
  mapping(uint => Product) private products;
  uint[] private productIds;
  Order[] private orders;

  uint private ALLOWED_RETURN_BLOCK_COUNT = 100;
  uint private nextProductId = 1;

  enum ProductActions { Created, Updated }
  enum OrderActions { Created, Returned }

  event ProductAction(uint productId, ProductActions action);
  event OrderAction(uint productId, uint quantity, address buyerAddress, OrderActions action);

  // Admin functions
  // We assume the name will be unique in our store (something like an SKU code)
  function createProduct(string calldata _name, uint _price, uint8 _quantity) public onlyOwner {
    require(bytes(_name).length > 0, "Name cannot be empty.");
    require(_price > 0, "Product cannot be free.");
    require(_quantity > 0, "Please provide at least one product quantity.");

    // TODO: trim name left and right here as well in the front-end
    uint productId = productIdByName(_name);

    if (productId > 0) {
      require(_quantity > products[productId].quantity, "Product exists. You can only increase its quantity.");

      products[productId].quantity = _quantity;
      
      emit ProductAction(productId, ProductActions.Updated);
    }
    else {
      productId = nextProductId;
      products[productId].id = productId;
      products[productId].name = _name;
      products[productId].price = _price;
      products[productId].quantity = _quantity;

      productIds.push(productId);
      nextProductId++;

      emit ProductAction(productId, ProductActions.Created);
    }
  }

  // Buyer functions
  // We asume a buyer can buy more than one product
  // order IDs not used for simplicity
  function placeOrder(uint _productId, uint8 _quantity) external payable {
    Product storage product = products[_productId];
    require(product.id > 0, "Product doesn't exist.");
    int existingOrderIndex = getOrderIndex(_productId, msg.sender);
    require(_quantity > 0, "You need to buy at least one product.");
    require(existingOrderIndex == -1, "Order exists. You cannot place more than one order for the same product.");
    require(product.quantity >= _quantity, "Unsufficient product quantity in stock.");
    require(msg.value == product.price * _quantity, "Please send the exact price amount.");

    product.quantity -= _quantity;
    orders.push(Order(_productId, _quantity, msg.sender, block.number));

    emit OrderAction(_productId, _quantity, msg.sender, OrderActions.Created);
  }

  // We assume buyer cannot partially return an order
  function returnOrder(uint _productId) external payable {
    Product storage product = products[_productId];
    require(product.id > 0, "Product doesn't exist.");
    int existingOrderIndex = getOrderIndex(_productId, msg.sender);
    require(existingOrderIndex > -1, "The order is not made by you.");
    Order memory existingOrder = orders[uint(existingOrderIndex)];
    require(block.number - existingOrder.createdAtBlock <= ALLOWED_RETURN_BLOCK_COUNT, "You can only return an order no later than 100 blocks of time.");

    product.quantity += existingOrder.productQuantity;
    uint amountToReturn = existingOrder.productQuantity * product.price;
    (bool sendSuccess, ) = address(msg.sender).call{value: amountToReturn}("");
    require(sendSuccess, "Failed to send refund.");
    removeOrderAtIndex(uint(existingOrderIndex));

    emit OrderAction(_productId, existingOrder.productQuantity, msg.sender, OrderActions.Returned);
  }

  // Helper functions
  function getStoreBalance() external view returns (uint) {
        return address(this).balance;
  }

  function getAllProducts() external view returns (Product[] memory) {
    // Looping through arrays is not a good idea due to performance and gas optimization and should be done off-chain in a web2 DB
    // However I've left it here to change it later on if there's time
    Product[] memory productsArray = new Product[](productIds.length);
    for (uint i = 0; i < productIds.length; i++) {
      Product memory product = products[productIds[i]];
      productsArray[i] = product;
    }
    return productsArray;
  }

  function getProductOrders(uint _productId) external view returns (Order[] memory) {
    // Looping through arrays is not a good idea due to performance and gas optimization and should be done off-chain in a web2 DB
    // However I've left it here to change it later on if there's time
    uint numberOfMatches;
    for(uint i = 0; i < orders.length; i++) {
      if (orders[i].productId == _productId) {
        numberOfMatches++;
      }
    }
    Order[] memory productOrders = new Order[](numberOfMatches);
    uint nextIndex;
    for(uint i = 0; i < orders.length; i++) {
      if (orders[i].productId == _productId) {
        productOrders[nextIndex] = orders[i];
        nextIndex++;
      }
    }
    return productOrders;
  }

  function getProductCount() external view returns (uint) {
    return productIds.length;
  }

  function productIdByName(string memory _name) private view returns (uint) {
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

  function getOrderIndex(uint _productId, address buyerAddress) private view returns (int) {
    for (uint i = 0; i < orders.length; i++) {
      if (orders[i].productId == _productId && orders[i].buyerAddress == buyerAddress) {
        return int(i);
      }
    }
    return -1;
  }

  function removeOrderAtIndex(uint _index) private {
    require(_index < orders.length, "Index out of bound.");
    for(uint i = _index; i < orders.length - 1; i++) {
      orders[i] = orders[i + 1];
    }
    orders.pop();
  }
}