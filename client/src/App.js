import './App.css';
import { utils } from 'ethers';
import getBlockchain from './ethereum.js';
import { useState, useEffect } from 'react';

function App() {

  const [contract, setContract] = useState(undefined);
  const [products, setProducts] = useState([]);
  const [orders, setOrders] = useState([]);

  useEffect(() => {
    const init = async () => {
      const { contract, provider } = await getBlockchain();
      setContract(contract);

      const filter = {
        address: contract.address,
        topics: [
          utils.id("OrderAction(uint256,uint256,address,uint8)")
        ]
      }
      provider.on(filter, (data) => {
        console.log(data)
        getProducts()
          // do whatever you want here
          // I'm pretty sure this returns a promise, so don't forget to resolve it
      })
    };

    init();

    if (contract) {
      getProducts();
    }
  }, [contract]);

  if (typeof contract === 'undefined') {
    return 'Loading...';
  }

  function buyProduct(productId, price) {
    contract.placeOrder(productId, 1, {value: price})
      .catch(err => alert(err.data.message.replace('Error: VM Exception while processing transaction: reverted with reason string ', '')))
  }

  function getProducts() {
    contract.getAllProducts().then((data) => {
      setProducts(data);
    })
  }

  function getOrders(productId) {
    contract.getProductOrders(productId).then((data) => {
      console.log(productId, data)
      setOrders(data);
    })
  }

  function getProductsListElement() {
    return products.map((product, index) => {
      return <li key={index}>
        {product.name} - Ξ{product.price.toNumber()} - {product.quantity} left <button onClick={() => buyProduct(product.id.toNumber(), product.price.toNumber())}>Buy Product</button> <button onClick={() => getOrders(product.id.toNumber())}>Get Product Orders</button></li>
    })
  }

  function getOrdersListElement() {
    return orders.map((order, index) => {
      return <li key={index}>
        {order.productId.toNumber()} - {order.productQuantity} - {order.buyerAddress}</li>
    })
  }

  return (
    <div className="App">
      <header className="App-header">
        <p>Products</p>
        <ul>
        {
          getProductsListElement()
        }
        </ul>

        <p>Orders</p>
        <ul>
        {
          getOrdersListElement()
        }
        </ul>
      </header>
    </div>
  );
}

export default App;
