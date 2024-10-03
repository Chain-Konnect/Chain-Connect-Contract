const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const dotenv = require('dotenv')
dotenv.config()

const totalSupply = 15000000000000  //15 trillion

module.exports = buildModule("ChainConnetTokenModule", (m) => {
    const total_supply = m.getParameter("totalSupply", totalSupply); // Set constructor params

    const ChainConnectTokenContract = m.contract("ChainConnectToken", [total_supply]); // attach params to module contract instance
    console.log('Building module ......');


    return { ChainConnectTokenContract };
});