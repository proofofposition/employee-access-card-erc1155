require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
require('dotenv').config({path:__dirname+'/.env'})
const {POLYGON_API_URL, OPTIMISM_GOERLI_API_URL, SEPOLIA_API_URL, GOERLI_API_URL, PRIVATE_KEY, REPORT_GAS} = process.env;
require('@openzeppelin/hardhat-upgrades');

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
    goerli: {
      url: GOERLI_API_URL,
      accounts: [
        PRIVATE_KEY
      ]
    },
    polygon: {
      url: POLYGON_API_URL,
      accounts: [
        PRIVATE_KEY
      ]
    },
    optimism_goerli: {
      url: OPTIMISM_GOERLI_API_URL,
      accounts: [
        PRIVATE_KEY
      ]
    },
    sepolia: {
      url: SEPOLIA_API_URL,
      accounts: [
        PRIVATE_KEY
      ]
    }
  },
  gasReporter: {
    enabled: !!(REPORT_GAS)
  }
};
