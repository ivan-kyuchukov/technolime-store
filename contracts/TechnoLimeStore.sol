//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Product.sol";

contract TechnoLimeStore is Ownable {

  struct ProductStruct {
    string name;
    string sku;
    uint price;
    uint quantity;
    TechnoLimeStore.Status status;
    Product product;
  }
  mapping(string => ProductStruct) public products;

  uint private testt = 0;
  function change() public {
    testt += 1;
  }

  function retrieve() public view returns (uint) {
    return testt;
  }

  enum Status { Created, Paid, Shipped }

  event StatusChange(string _sku, uint status, address _address);

  function createProduct(string memory _name, string memory _sku, uint _priceInWei, uint _quantity) public onlyOwner {
    Product product = new Product(this, _priceInWei, _sku);
    products[_sku].product = product;
    products[_sku].name = _name;
    products[_sku].sku = _sku;
    products[_sku].price = _priceInWei;
    products[_sku].quantity = _quantity;
    products[_sku].status = Status.Created;
    emit StatusChange(_sku, uint(products[_sku].status), address(product));
  }

  function handlePayment(string memory _sku) public payable {
    Product product = products[_sku].product;
    require(address(product) == msg.sender, "The product payment must be only called by the product.");
    require(product.priceInWei() == msg.value, "Not fully paid yet.");
    require(products[_sku].status == Status.Created, "Product is further in the supply chain.");

    products[_sku].status = Status.Paid;
    emit StatusChange(_sku, uint(products[_sku].status), address(product));
  }

  function handleShipping(string memory _sku) public onlyOwner {
    require(products[_sku].status == Status.Paid, "Product is further in the supply chain.");
    products[_sku].status = Status.Shipped;
    emit StatusChange(_sku, uint(products[_sku].status), address(products[_sku].product));
  }
}