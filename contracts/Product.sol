//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import './TechnoLimeStore.sol';

contract Product {
  string public sku;
  uint public priceInWei;
  bool public isPaid;

  TechnoLimeStore parentContract;

  constructor(TechnoLimeStore _parentContract, uint _priceInWei, string memory _sku) {
    parentContract = _parentContract;
    priceInWei = _priceInWei;
    sku = _sku;
  }

  receive() external payable {
    require(msg.value == priceInWei, "We don't support partial payments. Send exact amount!");
    require(!isPaid, "Product is already paid!");
    isPaid = true;
    (bool success, ) = address(parentContract).call{value: msg.value}(abi.encodeWithSignature("handlePayment(string)", sku));
    require(success, "Payment did not work!");
  }
}