import './App.css';
import getBlockchain from './ethereum.js';
import { useState, useEffect } from 'react';

function App() {

  const [contract, setContract] = useState(undefined);
  const [products, setProducts] = useState([]);
  const [orders, setOrders] = useState(null);
  const [newProduct, setNewProduct] = useState({});

  useEffect(() => {
    const init = async () => {
      const { contract } = await getBlockchain();
      setContract(contract);
    };
    init();
  }, []);

  useEffect(() => {
    if (contract) {
      getProducts()
    }
  }, [contract])

  function getProducts() {
    contract.getAllProducts()
      .then((data) => {
        const products = data.map(product => {
          return {
            id: product.id.toNumber(),
            name: product.name,
            price: product.price.toNumber(),
            quantity: product.quantity
          }
        })
      setProducts(products);
    })
  }

  if (typeof contract === 'undefined') {
    return <div>Loading...</div>;
  }

  function createProduct() {
    contract.createProduct(newProduct.name, newProduct.price, newProduct.quantity)
      .then(() => {
        contract.on('ProductAction', () => {
          getProducts();
        })
      })
      .catch(err => alert(err.data.message.replace('Error: VM Exception while processing transaction: reverted with reason string ', '')))
  }

  function buyProduct(product) {
    contract.placeOrder(product.id, 1, {value: product.price})
      .then(() => {
        contract.on('OrderAction', () => {
          getProducts();
        })
        setOrders(null);
      })
      .catch(err => alert(err.data.message.replace('Error: VM Exception while processing transaction: reverted with reason string ', '')))
  }

  function returnOrder(order) {
    contract.returnOrder(order.productId)
      .then(() => {
        setOrders(null);
        contract.on('OrderAction', () => {
          getProducts();
        })
      })
      .catch(err => alert(err.data.message.replace('Error: VM Exception while processing transaction: reverted with reason string ', '')))
  }

  function getOrders(productId) {
    contract.getProductOrders(productId)
      .then((data) => {
        const orders = data.map(order => {
          return {
            productId: order.productId.toNumber(),
            productQuantity: order.productQuantity,
            buyerAddress: order.buyerAddress
          }
        });
        setOrders(orders);
      })
  }

  function getProductsListElement() {
    if (products.length > 0) {
      return products.map((product, index) => {
        return (
          <div key={index}>
            {product.name} - {product.price} wei - {product.quantity} left 
            <button disabled={product.quantity === 0} onClick={() => buyProduct(product)} className="margin-l">
              Buy Product 
            </button> 
            <button onClick={() => getOrders(product.id)} className="margin-l">
              Get Product Orders 
            </button>
          </div>)
      })
    }
    return <div>No available products</div>
  }

  function getOrdersListElement() {
    if (orders.length > 0) {
      return orders.map((order, index) => {
        return (
          <div key={index}>
            ProductID: {order.productId} - {order.productQuantity} item(s) - Wallet: {order.buyerAddress}
            <button onClick={() => returnOrder(order)} className="margin-l">
              Return Order 
            </button>
          </div>)
      })
    }
    return <div>No orders for product</div>
  }
  
  function handleInputChange(event) {
    const fieldName = event.target.name;
    const fieldValue = event.target.value;
    
    switch (fieldName) {
      case 'name':
        setNewProduct({ ...newProduct, name: fieldValue });
        break;
      case 'price':
        setNewProduct({ ...newProduct, price: fieldValue });
        break;
      case 'quantity':
        setNewProduct({ ...newProduct, quantity: fieldValue });
        break;
      default:
    }
  }

  return (
    <div className="App">
      <header className="App-header">
        <p>New Product</p>
        <input name="name" type="text" placeholder='Product name..' onChange={handleInputChange} className="margin-bot"></input>
        <input name="price" type="number" placeholder='Price..' onChange={handleInputChange} className="margin-bot"></input>
        <input name="quantity" type="number" placeholder='Quantity..' onChange={handleInputChange} className="margin-bot"></input>
        <button onClick={() => createProduct()}>Create Product</button>
        <br></br>
        <p>Available Products</p>
        <ul>
          { getProductsListElement() }
        </ul>
        <p>Orders</p>
        <ul>
          { orders ? getOrdersListElement() : '' }
        </ul>
      </header>
    </div>
  );
}

export default App;
