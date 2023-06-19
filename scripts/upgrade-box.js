const { ethers, upgrades } = require("hardhat");
const UPGRADEABLE_CONTRACT_ADDRESS = "0x6AD61192B4a732e4ce54A68c5c993370490EA042";
async function main() {
    console.log("Starting...");
    const PoppAccessCard = await ethers.getContractFactory("PoppAccessCard");
    console.log("Deploying PoppAccessCard...");
    const poppAccessCard = await upgrades.upgradeProxy(UPGRADEABLE_CONTRACT_ADDRESS, PoppAccessCard);
    console.log("PoppAccessCard upgraded at :", poppAccessCard);
}

main();