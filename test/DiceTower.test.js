const D20Token = artifacts.require('./D20Token.sol');
const DiceTower = artifacts.require('./DiceTower.sol');

require('chai')
.use(require('chai-as-promised'))
.should()

contract('DiceTower', (accounts)=>{
    let d20TokenContract
    let contract

    before(async() => {
        d20TokenContract = await D20Token.deployed()
        contract = await DiceTower.deployed()
    })

    describe('deployment', async() => {
        it('deploys successfully', async() => {
            const address = contract.address
            assert.notEqual(address,0x0);
            assert.notEqual(address,'');
            assert.notEqual(address,null);
            assert.notEqual(address,undefined);
        })
        it('has d20Token contract', async() => {
            contract.setD20TokenContractAddress(d20TokenContract.address);
            const d20TokenContractResponse = await contract.getD20TokenContractAddress()
            assert.equal(d20TokenContractResponse, d20TokenContract.address)
        })
        it('has a name', async() => {
            const name = await contract.name()
            assert.equal(name, 'DiceTower')
        })
        it('it tracks dice rolls', async() => {
            //contract.roll();
            // -- Requires token + amount
            // -- Returns token
            // -- Rolls random number
            // -- Stores roll
            // -- Stores message/id with roll?
            // -- Find rolls by address
        })

    })

})
