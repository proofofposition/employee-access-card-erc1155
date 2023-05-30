require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
require("solidity-coverage");
require('dotenv').config({path:__dirname+'/.env'})
const { API_URL, PRIVATE_KEY, REPORT_GAS } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    // goerli: {
    //   url: API_URL,
    //   accounts: [
    //     PRIVATE_KEY,
    //   ],
    // },
  },
  gasReporter: {
    enabled: !!(REPORT_GAS)
  }
};
