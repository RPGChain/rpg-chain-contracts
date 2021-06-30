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

    describe('send', async() => {
        it('can send tokens', async() => {
            let initialBalance = await contract.balanceOf(accounts[0]);
            let amountToSend = 10000;
            await contract.transfer(accounts[1], amountToSend);
            let newBalance = await contract.balanceOf(accounts[0]);
            let newRecipientBalance = await contract.balanceOf(accounts[1]);
            assert.equal(newBalance, initialBalance-amountToSend);
            assert.equal(newRecipientBalance, amountToSend);
        })
    })

    describe('roll', async() => {
        it('rolls on send', async() => {
            let initialRollCount = await contract.rollsCountFrom(accounts[0]);
            await contract.transfer(accounts[1], 10000);
            let rollCount = await contract.rollsCountFrom(accounts[0]);
            assert.equal(parseInt(rollCount), parseInt(initialRollCount)+1);
        })
        it('gets roll for account', async() => {
            let rollResult = await contract.rollsResultFrom(accounts[0],0);
            console.log(rollResult);
            assert.equal(rollResult > 0 && rollResult <= 20, true);
        })
        it('gets roll for account and recipient', async() => {
            await contract.transfer(accounts[2], 10000);
            let senderRollCount = await contract.rollsCountFrom(accounts[0]);
            assert.equal(senderRollCount, 3);
            recipientRollCount = await contract.rollsCountFromTo(accounts[0], accounts[2]);
            assert.equal(recipientRollCount, 1);
            let recipientRollResult = await contract.rollsResultFromTo(accounts[0], accounts[2], 0);
            console.log(recipientRollResult);
            assert.equal(recipientRollResult > 0 && recipientRollResult <= 20, true);
        })
    })

})
