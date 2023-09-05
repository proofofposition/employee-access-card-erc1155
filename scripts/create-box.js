// scripts/create-box.js
const { ethers, upgrades } = require("hardhat");
// sepolia
//const employerBadgeAddress = "0x0FC0fd31C2465367047127a87Fda2a565EC0AcA5";
// polygon
const employerBadgeAddress = "0x5ac201677356b7862B88126cDcB3921FEfDcde82";
async function main() {
    console.log("Starting...");
    const PoppAccessCard = await ethers.getContractFactory("PoppAccessCard");
    const poppAccessCard = await upgrades.deployProxy(PoppAccessCard, [employerBadgeAddress], {timeout: 0});
    console.log("Deploying PoppAccessCard...");
    await poppAccessCard.deployed();
    console.log("PoppAccessCard deployed to:", poppAccessCard.address);
    let owner = await poppAccessCard.owner();
    console.log("Owner:", owner);
}

main();
