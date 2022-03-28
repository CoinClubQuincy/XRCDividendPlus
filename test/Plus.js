const Plus = artifacts.require("Plus");
const Abstract_Bank = artifacts.require("Plus");

//test Treasury
contract(Plus, accounts => {
    it("Launch Plus contract and Coinbank", async() =>  {
        let instance = await Plus.deployed("Q-Shards","QSHD",100,18);
        let CoinBank_Contract = await instance.Get_CoinBank();
        assert(await CoinBank_Contract, "Coinbank Address Expected");
        console.log(CoinBank_Contract);


        let trigger = await Abstract_Bank.at(CoinBank_Contract);
        let release = await trigger.Balance();
        console.log(release);
    })
})


// test abstract bank
contract(Abstract_Bank, accounts => {
    it("Launch Abstract Bank contract the Coinbank", async() =>  {
        let abstract = await Abstract_Bank.deployed();
        let bank = await abstract.Balance();
        console.log(bank);
    })
})