// scripts/create-box.js
const { ethers, upgrades } = require("hardhat");
const employerBadgeAddress = "0x1D831564d1c3FF8337530AE54C9D6B3f37ED5A5a";
async function main() {
    console.log("Starting...");
    const PoppAccessCard = await ethers.getContractFactory("PoppAccessCard");
    const poppAccessCard = await upgrades.deployProxy(PoppAccessCard, [employerBadgeAddress]);
    console.log("Deploying PoppAccessCard...");
    await poppAccessCard.deployed();
    console.log("PoppAccessCard deployed to:", poppAccessCard.address);
    let owner = await poppAccessCard.owner();
    console.log("Owner:", owner);
}

main();
