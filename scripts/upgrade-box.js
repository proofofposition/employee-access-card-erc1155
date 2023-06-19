const { ethers, upgrades } = require("hardhat");
const UPGRADEABLE_CONTRACT_ADDRESS = "";
async function main() {
    console.log("Starting...");
    const PoppAccessCard = await ethers.getContractFactory("PoppAccessCard");
    console.log("Deploying PoppAccessCard...");
    const poppAccessCard = await upgrades.upgradeProxy(UPGRADEABLE_CONTRACT_ADDRESS, PoppAccessCard);
    console.log("PoppAccessCard upgraded at :", poppAccessCard);
}

main();