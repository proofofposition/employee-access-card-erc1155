// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "popp-interfaces/IEmployerSft.sol";

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract EmployerSftMock is
ERC1155,
IEmployerSft {
    uint32 public employerId;

    constructor() ERC1155("https://test.com/{id}.json") {}

    function setEmployerId(uint32 _employerId) external {
        employerId = _employerId;
    }

    function employerIdFromWallet(address) external view returns (uint32) {
        return employerId;
    }
}
