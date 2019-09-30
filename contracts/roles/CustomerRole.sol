pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/access/Roles.sol";

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
