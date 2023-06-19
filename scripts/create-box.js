// scripts/create-box.js
const { ethers, upgrades } = require("hardhat");
const employerBadgeAddress = "0xbA48b6AC88761d8B153E50Ca882FB4Ae798f57df";
async function main() {
    console.log("Starting...");
    const PoppAccessCard = await ethers.getContractFactory("PoppAccessCard");
    const poppAccessCard = await upgrades.deployProxy(PoppAccessCard, [employerBadgeAddress]);
    console.log("Deploying PoppAccessCard...");
    await poppAccessCard.deployed();
    console.log("PoppAccessCard deployed to:", poppAccessCard.address);
}

main();
