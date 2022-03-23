const Plus = artifacts.require("Plus");

contract(Plus, accounts => {
    it("Launch Plus contract and Coinbank", () => {
        let instance = await Plus.deployed();
        let CoinBank_Contract = await instance.Get_CoinBank();
        assert.equal(await CoinBank_Contract.length, 1, "Coinbank Address Expected");
        console.log(CoinBank_Contract);
    })
})