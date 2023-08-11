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
            // deploy employer badge mock
            const EmployerSftMockFactory = await ethers.getContractFactory("EmployerSftMock");
            this.employerSft = await upgrades.deployProxy(EmployerSftMockFactory)
            // deploy contract under test
            const PoppAccessCard = await ethers.getContractFactory("PoppAccessCard");
            myContract = await upgrades.deployProxy(PoppAccessCard, [this.employerSft.address]);

            [owner, alice, bob, connie] = await ethers.getSigners();
            const balance0ETH = await ethers.provider.getBalance(myContract.address);
            console.log("\t", " ⚖️ Starting Contract ETH balance: ", balance0ETH.toString());

            // mint employer verification
            let mintResult = await myContract
                .connect(owner)
                .mintNewAccessCard(alice.address, "TOKEN_URI", 'hooli');

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
                    .mintNewAccessCard(bob.address, "TOKEN_URI", 'hoooli')
            ).to.be.revertedWith("Ownable: caller is not the owner");

            // test non-transferable
            await expect(
                myContract.safeTransferFrom(owner.address, alice.address, 1, 1, "0x")
            ).to.be.revertedWithCustomError(myContract, 'NonTransferable');
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

        describe("addToMyEmployer()", function () {
            it("Should be able to add a wallet to my employer", async function () {
                await this.employerSft.setEmployerKey('hooli');
                // add a new wallet
                let mintResult = await myContract
                    .connect(alice)
                    .addToMyEmployer(connie.address);
                // check uri is the same for the new wallet token
                let txResult = await mintResult.wait(1);
                let _tokenId = txResult.events[0].args._tokenId.toString();
                expect(_tokenId).to.be.equal("1");
            });

            it("Should fail if user tries to add to a non-existent employer", async function () {
                // add a new wallet
                await expect(
                    myContract
                        .connect(bob)
                        .addToMyEmployer(connie.address)
                ).to.be.revertedWithCustomError(myContract, 'MissingEmployerBadge');
            });

            it("Should be able to remove from employer (admin)", async function () {
                await myContract
                    .connect(owner)
                    .removeFromTeam(alice.address, tokenId)

                let balance = await myContract.balanceOf(alice.address, tokenId);
                expect(balance.toBigInt()).to.be.equal(0);
            });

            it("Should be able to remove from employer (employer member)", async function () {
                await this.employerSft.setEmployerKey('hooli');
                await myContract
                    .connect(alice)
                    .removeFromMyTeam(alice.address)

                let balance = await myContract.balanceOf(alice.address, tokenId);
                expect(balance.toBigInt()).to.be.equal(0);
            });

            it("Should fail if user tries to remove from a employer that you don't belong to", async function () {
                // add a new wallet
                await expect(
                    myContract
                        .connect(bob)
                        .removeFromTeam(alice.address, tokenId)
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
