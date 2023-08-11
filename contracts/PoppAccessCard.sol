// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC165Upgradeable.sol";
import "popp-interfaces/IEmployerSft.sol";

/**
 * @title PoppAccessCard
 * @notice This contract represents an employee access card.
 It is minted by an employer and assigned to an employee as Proof of their Position in the Organization.
 * @dev This contract is an ERC721 token that is minted by an admin or verified POPP employer and assigned to a new employee.
 * Desired Features
 * - Mint a new employee access card (admin only)
 * - Add a wallet to an employer (admin only)
 * - Burn Tokens (admin only?)
 * - ERC1155 full interface (base, metadata, enumerable)
*/
contract PoppAccessCard is
ERC1155Upgradeable,
ERC1155URIStorageUpgradeable,
OwnableUpgradeable,
UUPSUpgradeable
{
    //////////////
    // Errors  //
    ////////////
    error MissingEmployerBadge();
    error NonTransferable();
    //////////////////////
    // State Variables //
    ////////////////////
    uint256 private _tokenIdCounter;
    IEmployerSft private employerSft;
    mapping(bytes32 => uint256) private _employerKeyToTokenId;
    /////////////
    // Events //
    ///////////
    event NewAccessCardMinted(uint256 _tokenId, address _to, string _tokenURI, string _employerKey);
    event UriSet(uint256 _tokenId, string _tokenURI);
    event BaseUriSet(string _baseUri);
    event WalletAddedToTeam(address _wallet, uint256 _tokenId);
    event WalletRemovedFromTeam(address _wallet, uint256 _tokenId);
    event TokenBurned(uint256 _tokenId);

    function initialize(address _employerSftAddress) initializer public {
        __ERC1155_init("ipfs://");
        __ERC1155URIStorage_init();
        _setBaseURI("ipfs://");
        __Ownable_init();
        __UUPSUpgradeable_init();
        employerSft = IEmployerSft(_employerSftAddress);
        _tokenIdCounter = 0;
    }

    /**
     * @dev Mint a new Employee Access Card. This is done when onboarding a new employer.
     *
     * @return uint256 representing the newly minted token id
     */
    function mintNewAccessCard(
        address _to,
        string memory _tokenURI,
        string memory _employerKey
    ) external onlyOwner returns (uint256) {
        uint256 _tokenId = _mintToken(_to);
        _setURI(_tokenId, _tokenURI);
        emit NewAccessCardMinted(_tokenId, _to, _tokenURI, _employerKey);

        _employerKeyToTokenId[keccak256(abi.encodePacked(_employerKey))] = _tokenId;
        return _tokenId;
    }

    /**
     * @dev Mint a pre-verified employer token and transfer to a new wallet
     * this is an admin function for setting up a employer's wallets
     *
     * @return uint256 representing the newly minted token id
     */
    function addEmployee(address _to, uint256 _tokenId) external onlyOwner returns (uint256) {
        emit WalletAddedToTeam(_to, _tokenId);

        return _addToEmployer(_to, _tokenId);
    }

    /**
    * @dev Mint a pre-verified employer token and transfer to a new wallet
     * we allow access card owners to add to their employer
     *
     * @return uint256 representing the newly minted token id
     */
    function addToMyEmployer(address _to) external returns (uint256) {
        string memory _employerKey = employerSft.employerKeyFromWallet(msg.sender);
        if (bytes(_employerKey).length == 0) {
            revert MissingEmployerBadge();
        }
        uint256 _tokenId = _employerKeyToTokenId[keccak256(abi.encodePacked(_employerKey))];
        emit WalletAddedToTeam(_to, _tokenId);

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
        _tokenIdCounter++;
        return _addToEmployer(_to, _tokenIdCounter);
    }

    /**
     * @dev remove a wallet from a employer
     * This can only be done by a employer member.
     * note: A wallet can remove itself from a employer
     */
    function removeFromMyTeam(address _from) external {
        string memory _employerKey = employerSft.employerKeyFromWallet(msg.sender);
        uint256 _tokenId = _employerKeyToTokenId[keccak256(abi.encodePacked(_employerKey))];

        require(_tokenId != 0, "You need to register your employer");
        emit WalletRemovedFromTeam(_from, _tokenId);

        super._burn(_from, _tokenId, 1);
    }

    /**
     * @dev remove a wallet from a employer
     * This can only be done by an admin user
     */
    function removeFromTeam(
        address _from,
        uint256 _id
    ) public onlyOwner {
        emit WalletRemovedFromTeam(_from, _id);
        super._burn(_from, _id, 1);
    }

    /**
   * @dev Sets `tokenURI` as the tokenURI of `tokenId`.
     */
    function setURI(uint256 tokenId, string memory tokenURI) external onlyOwner {
        _setURI(tokenId, tokenURI);
        emit UriSet(tokenId, tokenURI);
    }

    /**
    * @dev Sets `baseURI` as the `_baseURI` for all tokens
     */
    function setBaseURI(string memory baseURI) external onlyOwner {
        _setBaseURI(baseURI);
    }


    // The following functions are overrides required by Solidity.
    function uri(uint256 tokenId) public view virtual override(ERC1155Upgradeable, ERC1155URIStorageUpgradeable)  returns (string memory) {
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
    ) internal virtual override(ERC1155Upgradeable) {
        if (from != address(0) && to != address(0)) {
            revert NonTransferable();
        }
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyOwner
    override
    {}
}
