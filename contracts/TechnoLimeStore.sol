//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Ownable.sol";

contract TechnoLimeStore is Ownable {

  struct Order {
    uint8 productQuantity;
    address buyerAddress;
    uint createdAtBlock;
  }

  struct Product {
    string name;
    uint price;
    uint8 quantity;
    mapping(address => Order) orders;
  }
  
  mapping(string => Product) private products;

  uint private ALLOWED_RETURN_BLOCK_COUNT = 100;

  enum ProductActions { Created, Updated }
  enum OrderActions { Created, Returned }

  event ProductAction(string productName, ProductActions action);
  event OrderAction(string productName, uint quantity, address buyerAddress, OrderActions action);

  // We assume the name will be unique in our store (something like an SKU code)
  function createProduct(string calldata _name, uint _price, uint8 _quantity) public onlyOwner {
    require(bytes(_name).length > 0, "Name cannot be empty.");
    require(_price > 0, "Product cannot be free.");
    require(_quantity > 0, "Quantity cannot be zero.");

    bool productExists = bytes(products[_name].name).length > 0 ? true : false;

    if (productExists) {
      require(_quantity > products[_name].quantity, "Product exists. You can only increase its quantity.");

      products[_name].quantity = _quantity;
      
      emit ProductAction(_name, ProductActions.Updated);
    }
    else {
      products[_name].name = _name;
      products[_name].price = _price;
      products[_name].quantity = _quantity;

      emit ProductAction(_name, ProductActions.Created);
    }
  }

  // We asume a buyer can buy more than one product
  function placeOrder(string calldata _productName, uint8 _quantity) external payable {
    Product storage product = products[_productName];
    require(_quantity > 0, "You need to buy at least one product.");
    require(bytes(product.name).length > 0, "Product doesn't exist.");
    require(product.orders[msg.sender].buyerAddress == address(0), "Order exists. You cannot place more than one order for the same product.");
    require(product.quantity >= _quantity, "Unsufficient product quantity in stock.");
    require(msg.value == product.price * _quantity, "Please send the exact price amount.");

    product.quantity -= _quantity;
    product.orders[msg.sender] = Order(_quantity, msg.sender, block.number);

    emit OrderAction(_productName, _quantity, msg.sender, OrderActions.Created);
  }

  // We assume buyer cannot partially return an order
  function returnOrder(string calldata _productName) external payable {
    Product storage product = products[_productName];
    require(bytes(product.name).length > 0, "Product doesn't exist.");
    require(product.orders[msg.sender].buyerAddress == msg.sender, "You have no orders for this product.");
    Order memory existingOrder = product.orders[msg.sender];
    require(block.number - existingOrder.createdAtBlock <= ALLOWED_RETURN_BLOCK_COUNT, "You can only return an order no later than 100 blocks of time.");

    uint8 existingOrderProdQuantity = existingOrder.productQuantity;
    product.quantity += existingOrder.productQuantity;
    uint amountToReturn = existingOrder.productQuantity * product.price;
    (bool sendSuccess, ) = address(msg.sender).call{value: amountToReturn}("");
    require(sendSuccess, "Failed to send refund.");
    delete product.orders[msg.sender];

    emit OrderAction(product.name, existingOrderProdQuantity, msg.sender, OrderActions.Returned);
  }

  function getStoreBalance() external view returns (uint) {
    return address(this).balance;
  }

  function getProductDetails(string calldata _productName) external view returns (string memory, uint, uint8) {
    return (products[_productName].name, products[_productName].price, products[_productName].quantity);
  }
}