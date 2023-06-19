// scripts/create-box.js
const { ethers, upgrades } = require("hardhat");

async function main() {
    console.log("Starting...");
    const PoppAccessCard = await ethers.getContractFactory("PoppAccessCard");
    const poppAccessCard = await upgrades.deployProxy(PoppAccessCard);
    console.log("Deploying PoppAccessCard...");
    await poppAccessCard.deployed();
    console.log("PoppAccessCard deployed to:", poppAccessCard.address);
}

main();
