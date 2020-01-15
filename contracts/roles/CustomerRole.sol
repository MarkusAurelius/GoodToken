// The MIT License(MIT)

// Copyright(c) 2016 - 2019 zOS Global Limited

// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files(the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
//   distribute, sublicense, and / or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:

// The above copyright notice and this permission notice shall be included
//   in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// Based on OpenZeppelin's https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/roles/MinterRole.sol

pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";

/**
    @notice Implements a access control for a customer role,
    which will be responsible for purchasing organic products
    @dev not detailed documentation, since its based on OpenZeppelin.
    Take a look at the repo for further info.
 */
contract CustomerRole {
    using Roles for Roles.Role;

    event CustomerAdded(address indexed account);
    event CustomerRemoved(address indexed account);

    Roles.Role private _customers;

    constructor () internal {
        _addCustomer(msg.sender);
    }

    modifier onlyCustomer() {
        require(isCustomer(msg.sender), "CustomerRole: caller does not have the Customer role");
        _;
    }
  

    function isCustomer(address account) public view returns (bool) {
        return _customers.has(account);
    }

    function addCustomer(address account) public onlyCustomer() {
        _addCustomer(account);
    }

    function renounceCustomer() public {
        _removeCustomer(msg.sender);
    }

    function _addCustomer(address account) internal {
        _customers.add(account);
        emit CustomerAdded(account);
    }

    function _removeCustomer(address account) internal {
        _customers.remove(account);
        emit CustomerRemoved(account);
    }
}
