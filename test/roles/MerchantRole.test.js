const { accounts, contract } = require('@openzeppelin/test-environment');

const { shouldBehaveLikePublicRole } = require('./PublicRole.behavior');
const MerchantRoleMock = contract.fromArtifact('MerchantRoleMock');

describe('MerchantRole', function () {
  const [ merchant, otherMerchant, ...otherAccounts ] = accounts;

  beforeEach(async function () {
    this.contract = await MerchantRoleMock.new({ from: merchant });
    await this.contract.addMerchant(otherMerchant, { from: merchant });
  });

  shouldBehaveLikePublicRole(merchant, otherMerchant, otherAccounts, 'Merchant');
});