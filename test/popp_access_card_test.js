//
// this script executes when you run 'yarn test'
//
// you can also test remote submissions like:
// CONTRACT_ADDRESS=0x43Ab1FCd430C1f20270C2470f857f7a006117bbb yarn test --network rinkeby
//
// you can even run mint commands if the tests pass like:
// yarn test && echo "PASSED" || echo "FAILED"
//
const {expect} = require("chai");

describe("🚩 Full Popp Employee Access Card Flow", function () {
    this.timeout(120000);

    let myContract;
    // eslint-disable-next-line no-unused-vars
    let owner;
    let alice;
    let connie;
    let bob;
    let tokenId;

    describe("Popp Employee Access", function () {
        beforeEach(async function () {
            const PoppAccessCard = await ethers.getContractFactory("PoppAccessCard");

            myContract = await PoppAccessCard.deploy();

            [owner, alice, bob, connie] = await ethers.getSigners();
            const balance0ETH = await ethers.provider.getBalance(myContract.address);
            console.log("\t", " ⚖️ Starting Contract ETH balance: ", balance0ETH.toString());

            // mint employer verification
            let mintResult = await myContract
                .connect(owner)
                .mintNewAccessCard(alice.address, "TOKEN_URI");

            let batch = await myContract.balanceOfBatch([alice.address], [1])
            expect(batch.toString()).to.equal('1');
            // check transaction was successful
            let txResult = await mintResult.wait(1);
            tokenId = txResult.events[0].args.id.toString();

            expect(txResult.status).to.equal(1);

            let balance = await myContract.balanceOf(alice.address, tokenId);
            expect(balance.toBigInt()).to.be.equal(1);

            // check token uri
            let uri = await myContract.uri(tokenId);
            expect(uri).to.be.equal("ipfs://TOKEN_URI");

            await expect(
                myContract
                    .connect(bob)
                    .mintNewAccessCard(bob.address, "TOKEN_URI")
            ).to.be.revertedWith("Ownable: caller is not the owner");

            // test non-transferable
            await expect(
                myContract.safeTransferFrom(owner.address, alice.address, 1, 1, "0x")
            ).to.be.revertedWith("Employee Access Cards are non-transferable");
        });

        describe("addEmployee()", function () {
            it("Owner should add a wallet to a pre-existing access card", async function () {
                // add to employer
                await myContract
                    .addEmployee(connie.address, 1);

                expect(await myContract.balanceOf(connie.address, 1)).to.equal(
                    1
                );
            });

            it("Should fail non-owner to add to employer", async function () {
                // add a new wallet
                await expect(
                    myContract
                        .connect(bob)
                        .addEmployee(connie.address, 1)
                ).to.be.revertedWith("Ownable: caller is not the owner");
            });
        });
    });

    describe("Other Functions", function () {
        it("Test other functions", async function () {
            // add to employer
            expect(await myContract.supportsInterface(0x01ffc9a7)).to.equal(
                true
            );

            expect(await myContract.owner()).to.equal(
                owner.address
            );

            await myContract.transferOwnership(alice.address)

            expect(await myContract.owner()).to.equal(
                alice.address
            );

            await myContract.connect(alice).transferOwnership(owner.address)
        });
    });
});
