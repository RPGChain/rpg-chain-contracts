const D20Token = artifacts.require('./D20Token.sol');

require('chai')
.use(require('chai-as-promised'))
.should()

contract('D20Token', (accounts)=>{
    let contract

    before(async() => {
        contract = await D20Token.deployed()
    })

    describe('deployment', async() => {
        it('deploys successfully', async() => {
            const address = contract.address
            assert.notEqual(address,0x0);
            assert.notEqual(address,'');
            assert.notEqual(address,null);
            assert.notEqual(address,undefined);
        })
        it('has a name', async() => {
            const name = await contract.name()
            assert.equal(name, 'D20Token')
        })
        it('has a symbol', async() => {
            const symbol = await contract.symbol()
            assert.equal(symbol, 'D20')
        })
    })

    describe('supply', async() => {
        it('has a max supply', async() => {
            const totalSupply = await contract.totalSupply();
            let expected = 20000000000000000000000000;
            assert.equal(totalSupply, expected);
        })
        it('can not exceed max supply', async() => {
            try {
                await contract.mint(100000000000000000);
                assert.fail("The transaction should have thrown an error");
            }
            catch (err) {
                assert.include(err.message, "NUMERIC_FAULT", "The error message should contain 'NUMERIC_FAULT'");
            }
        })
        it('is burnable', async() => {
            let initialBalance = await contract.balanceOf(accounts[0]);
            contract.burn(1000);
            let newBalance = await contract.balanceOf(accounts[0]);
            let expected = initialBalance - 1000;
            assert.equal(newBalance, expected, "Balance should be reduced.");
        })
    })

})
