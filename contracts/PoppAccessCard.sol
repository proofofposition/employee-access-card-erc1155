// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// Desired Features
// - Mint a new employee access card (admin only)
// - Add a wallet to an employer (admin only)
// - Burn Tokens (admin only?)
// - ERC1155 full interface (base, metadata, enumerable)
contract PoppAccessCard is
ERC1155,
Ownable
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor () ERC1155("ipfs://{id}") {}

    /**
     * @dev Mint a new Employee Access Card. This is done when onboarding a new employer.
     *
     * @return uint256 representing the newly minted token id
     */
    function mintNewAccessCard(address _to) external onlyOwner returns (uint256) {
        return _mintToken(_to);
    }

    /**
     * @dev Mint a pre-verified employer token and transfer to a new wallet
     * this is an admin function for setting up a employer's wallets
     *
     * @return uint256 representing the newly minted token id
     */
    function addEmployee(address _to, uint256 _tokenId) external onlyOwner returns (uint256) {
        return _addToEmployer(_to, _tokenId);
    }

    /**
    * @dev Mint a new token and add to a employer
     * this is an internal function that is called by `mintNewAccessCard` and `addToEmployer`
     * 1. Mint the token
     * 2. Set the token to the wallet
     * @return uint256 representing the newly minted token id
     */
    function _addToEmployer(address _to, uint256 _tokenId) internal returns (uint256) {
        _mint(_to, _tokenId, 1, "");

        return _tokenId;
    }

    /**
     * @dev Mint a new SFT. This is an internal function that is called by
     * `mintNewAccessCard` and `addToEmployer`.
     * 1. Mint the token
     * 2. Set the token to the wallet
     * @return uint256 representing the newly minted token id
     */
    function _mintToken(address _to) internal returns (uint256) {
        _tokenIdCounter.increment();
        uint256 _tokenId = _tokenIdCounter.current();

        return _addToEmployer(_to, _tokenId);
    }

    /**
     * @dev remove a wallet from a employer
     * This can only be done by an admin user
     */
    function removeFromEmployer(
        address _from,
        uint256 _id
    ) public onlyOwner {
        super._burn(_from, _id, 1);
    }

    /**
    * @dev destroy the contract and return the funds to the owner
    */
    function selfDestruct() public onlyOwner {
        selfdestruct(payable(owner()));
    }

    /**
    * @dev This override is to make the token non-transferable
    */
    function _beforeTokenTransfer(
        address,
        address from,
        address to,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) internal virtual override(ERC1155) {
        require(from == address(0) || to == address(0), "Employee Access Cards are non-transferable");
    }
}
