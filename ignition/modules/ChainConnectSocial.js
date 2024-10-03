const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const dotenv = require('dotenv')
dotenv.config()

const  tokenAddress = ""

module.exports = buildModule("ChainConnectSocialModule", (m) => {
    const tokenAddr = m.getParameter("tokenAddress", tokenAddress); // Set constructor params

    const chainConnectSocialContract = m.contract("ChainConnetSocial", [tokenAddr]); // attach params to module contract instance
    console.log('Building module ......');
    

    return { chainConnectSocialContract };
});