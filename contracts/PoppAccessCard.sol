// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "popp-interfaces/IAccessCardSft.sol";
import "popp-interfaces/IEmployerSft.sol";

// Desired Features
// - Mint a new employee access card (admin only)
// - Add a wallet to an employer (admin only)
// - Burn Tokens (admin only?)
// - ERC1155 full interface (base, metadata, enumerable)
contract PoppAccessCard is
ERC1155,
ERC1155URIStorage,
Ownable,
IAccessCardSft
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    IEmployerSft private employerSft;


    constructor (address _employerSftAddress) ERC1155("https://ipfs.io/ipfs/") {
        _setBaseURI("https://ipfs.io/ipfs/");
        employerSft = IEmployerSft(_employerSftAddress);
    }

    /**
     * @dev Mint a new Employee Access Card. This is done when onboarding a new employer.
     *
     * @return uint256 representing the newly minted token id
     */
    function mintNewAccessCard(address _to, string memory _tokenURI) external onlyOwner returns (uint256) {
        uint256 _tokenId = _mintToken(_to);
        _setURI(_tokenId, _tokenURI);

        return _tokenId;
    }

    /**
     * @dev Sets `tokenURI` as the tokenURI of `tokenId`.
     */
    function setURI(uint256 tokenId, string memory tokenURI) external onlyOwner {
        _setURI(tokenId, tokenURI);
    }

    /**
    * @dev Sets `baseURI` as the `_baseURI` for all tokens
     */
    function setBaseURI(string memory baseURI) external onlyOwner {
        _setBaseURI(baseURI);
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
    * @dev Mint a pre-verified employer token and transfer to a new wallet
     * we allow access card owners to add to their employer
     *
     * @return uint256 representing the newly minted token id
     */
    function addToMyEmployer(address _to) external returns (uint256) {
        uint256 _employerId = employerSft.employerIdFromWallet(msg.sender);
        require(_employerId != 0, "You need to be a POPP verified employer to do this.");

        return _addToEmployer(_to, _employerId);
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
     * This can only be done by a employer member.
     * note: A wallet can remove itself from a employer
     */
    function removeFromMyEmployer(address _from) public {
        uint256 _employerId = employerSft.employerIdFromWallet(msg.sender);
        require(_employerId != 0, "You need to register your employer");

        super._burn(_from, _employerId, 1);
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

    // The following functions are overrides required by Solidity.
    function uri(uint256 tokenId) public view virtual override(ERC1155, ERC1155URIStorage)  returns (string memory) {
        return super.uri(tokenId);
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
