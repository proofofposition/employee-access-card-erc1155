// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "popp-interfaces/IEmployerSft.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";

contract EmployerSftMock is
ERC1155Upgradeable,
IEmployerSft {
    string public employerKey;

    function setEmployerKey(string memory _employerKey) external {
        employerKey = _employerKey;
    }

    function employerKeyFromWallet(address _address) external view returns (string memory) {
        return employerKey;
    }

    function addToMyTeam(address) view external returns (uint256) {
        return 1;
    }

    function removeFromMyTeam(address, uint32) pure external {
        return;
    }

    function invalidFrom(address) external pure returns (uint32) {
        return 123;
    }
}
