const Plus = artifacts.require("Plus");

contract(Plus, accounts => {
    it("Launch Plus contract and Coinbank", async() =>  {
        let instance = await Plus.deployed("Q-Shards","QSHD",100,18);
        let CoinBank_Contract = await instance.Get_CoinBank();
        assert(await CoinBank_Contract, "Coinbank Address Expected");
        console.log(CoinBank_Contract);
    })
})

contract(Plus, accounts => {
    it("Launch Plus contract and Coinbank", async() =>  {
        let instance = await Plus.deployed("Q-Shards","QSHD",100,18);
        let Balance = await instance.Balance();
        //assert(await Balance, "Coinbank Address Expected");
        console.log(Balance);

        coinbank = await Plus.deployed();
        let bank = await coinbank.Get_CoinBank()

        console.log(bank)
    })
})

