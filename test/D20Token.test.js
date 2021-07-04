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

    describe('funds', async() => {
        it('can withdrawl contract funds', async() => {
            let contractBalanceInitial = await contract.balanceOf(contract.address);
            let account = accounts[0];
            let accountBalanceInitial = await contract.balanceOf(account);
            console.log(contract.address);
            console.log(contractBalanceInitial);
            console.log(account);
            console.log(accountBalanceInitial);
            /*let user1 = accounts[1];
            let user1Balance = await contract.balanceOf(user1);
            console.log(contract.address);
            console.log(wallet);
            console.log(walletBalance);
            console.log(user1);
            console.log(user1Balance);
            // Start user1 with some funds +10000
            await contract.transfer(user1, 10000);
            user1Balance = await contract.balanceOf(user1);
            console.log(user1Balance);
            // user accidentally sends 1000 to the contract address*/
            await contract.transfer(contract.address, 10000);
            let contractBalance = await contract.balanceOf(contract.address);
            let accountBalance = await contract.balanceOf(account);
            console.log(contractBalance);
            console.log(accountBalance);

            //let withdrawalResponse = await contract.withdrawalToWallet();
            let withdrawalResponse = await contract.withdrawalToWallet.call();
            console.log(withdrawalResponse);
            
            contractBalance = await contract.balanceOf(contract.address);
            accountBalance = await contract.balanceOf(account);
            console.log(contractBalance);
            console.log(accountBalance);

            //assert.equal(accountBalance, accountBalanceInitial);
            assert.equal(contractBalance, contractBalanceInitial);
            
        })
    })

})
