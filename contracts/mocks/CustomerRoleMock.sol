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

// Based on OpenZeppelin's https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/mocks/MinterRoleMock.sol

pragma solidity ^0.5.0;

import "../roles/CustomerRole.sol";

contract CustomerRoleMock is CustomerRole {
    constructor() public CustomerRole() {
        super._addCustomer(msg.sender);
    }

    function addCustomer(address account) public onlyCustomer {
        super._addCustomer(account);
    }

    function removeCustomer(address account) public {
        _removeCustomer(account);
    }

    function onlyCustomerMock() public view onlyCustomer {
        // solhint-disable-previous-line no-empty-blocks
    }

    // Causes a compilation error if super._removeCustomer is not internal
    function _removeCustomer(address account) internal {
        super._removeCustomer(account);
    }
}
