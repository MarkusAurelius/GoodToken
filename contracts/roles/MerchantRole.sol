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
    @notice Implements a access control for a Merchant role,
    which will be responsible for selling organic products
    @dev not detailed documentation, since its based on OpenZeppelin.
    Take a look at the repo for further info.
 */
contract MerchantRole {
    using Roles for Roles.Role;

    event MerchantAdded(address indexed account);
    event MerchantRemoved(address indexed account);

    Roles.Role private _merchants;

    constructor () internal {
        _addMerchant(msg.sender);
    }

    modifier onlyMerchant() {
        require(isMerchant(msg.sender), "MerchantRole: caller does not have the Merchant role");
        _;
    }
  

    function isMerchant(address account) public view returns (bool) {
        return _merchants.has(account);
    }

    function addMerchant(address account) public onlyMerchant() {
        _addMerchant(account);
    }

    function renounceMerchant() public {
        _removeMerchant(msg.sender);
    }

    function _addMerchant(address account) internal {
        _merchants.add(account);
        emit MerchantAdded(account);
    }

    function _removeMerchant(address account) internal {
        _merchants.remove(account);
        emit MerchantRemoved(account);
    }
}
