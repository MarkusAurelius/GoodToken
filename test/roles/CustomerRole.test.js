const { accounts, contract } = require('@openzeppelin/test-environment');

const { shouldBehaveLikePublicRole } = require('./PublicRole.behavior');
const CustomerRoleMock = contract.fromArtifact('CustomerRoleMock');

describe('CustomerRole', function () {
  const [ customer, otherCustomer, ...otherAccounts ] = accounts;

  beforeEach(async function () {
    this.contract = await CustomerRoleMock.new({ from: customer });
    await this.contract.addCustomer(otherCustomer, { from: customer });
  });

  shouldBehaveLikePublicRole(customer, otherCustomer, otherAccounts, 'Customer');
});