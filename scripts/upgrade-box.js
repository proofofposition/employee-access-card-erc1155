const { ethers, upgrades } = require("hardhat");
// sepolia
const UPGRADEABLE_CONTRACT_ADDRESS = "0x08177C140DEa15E8DeAE3C3c6d6Ce6aca34C215B";
async function main() {
    console.log("Starting...");
    const PoppAccessCard = await ethers.getContractFactory("PoppAccessCard");
    console.log("Deploying PoppAccessCard...");
    const poppAccessCard = await upgrades.upgradeProxy(UPGRADEABLE_CONTRACT_ADDRESS, PoppAccessCard);
    console.log("PoppAccessCard upgraded at :", poppAccessCard);
}

main();