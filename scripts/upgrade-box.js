const { ethers, upgrades } = require("hardhat");
// sepolia
const UPGRADEABLE_CONTRACT_ADDRESS = "0xD5eA03415E473ef541FC114B967b8ed9C06E2C80";
// polygon
// const UPGRADEABLE_CONTRACT_ADDRESS = "0x35d87F21a2114B626f1bC6A133a8e28F16567e6D";
async function main() {
    console.log("Starting...");
    const PoppAccessCard = await ethers.getContractFactory("PoppAccessCard");
    console.log("Deploying PoppAccessCard...");
    const poppAccessCard = await upgrades.upgradeProxy(UPGRADEABLE_CONTRACT_ADDRESS, PoppAccessCard);
    console.log("PoppAccessCard upgraded at :", poppAccessCard);
}

main();