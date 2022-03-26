const Plus = artifacts.require("Plus");
//test Treasury
contract(Plus, accounts => {
    it("Launch Plus contract and Coinbank", async() =>  {
        let instance = await Plus.deployed("Q-Shards","QSHD",100,18);
        let CoinBank_Contract = await instance.Get_CoinBank();
        assert(await CoinBank_Contract, "Coinbank Address Expected");
        console.log(CoinBank_Contract);
    })
})

//Test CoinBank
contract(Plus, accounts => {
    it("Launch Plus contract and Coinbank", async() =>  {
        let instance = await Plus.deployed("Q-Shards","QSHD",100,18);

        console.log(Balance);

        coinbank = await Plus.deployed();
        let bank = await coinbank.Get_CoinBank()

        Bank = Child.at(bank);
        //BankBalance = await Bank.Balance();

        console.log(bank)

    })
})

