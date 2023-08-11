const { ethers, upgrades } = require("hardhat");
// sepolia
const UPGRADEABLE_CONTRACT_ADDRESS = "0x336D287D40d05A98aD765093aAF96A2A83b1645F";
async function main() {
    console.log("Starting...");
    const PoppAccessCard = await ethers.getContractFactory("PoppAccessCard");
    console.log("Deploying PoppAccessCard...");
    const poppAccessCard = await upgrades.upgradeProxy(UPGRADEABLE_CONTRACT_ADDRESS, PoppAccessCard);
    console.log("PoppAccessCard upgraded at :", poppAccessCard);
}

main();