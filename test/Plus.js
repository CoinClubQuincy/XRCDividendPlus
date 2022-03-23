const Plus = artifacts.require("Plus");

contract(Plus, accounts => {
    it("Launch Plus contract and Coinbank", async() =>  {
        let instance = await Plus.deployed("Q-Shards","QSHD",100,18);
        let CoinBank_Contract = await instance.Get_CoinBank();
        //assert.equal(await CoinBank_Contract.length, 1, "Coinbank Address Expected");
        console.log(CoinBank_Contract);
    })
})