const Plus = artifacts.require("Plus");
const Abstract_Bank = artifacts.require("CoinBank");

//test Treasury
contract(Plus, accounts => {
    it("Launch Plus contract and Coinbank", async() =>  {
        let instance = await Plus.deployed("Q-Shards","QSHD",100,18);
        let CoinBank_Contract = await instance.Get_CoinBank();
        assert(await CoinBank_Contract, "Coinbank Address Expected");
        console.log(instance.address);

        let trigger = await Abstract_Bank.at(CoinBank_Contract); 
        //----
        web3.eth.sendTransaction({
            to:accounts[String(trigger.address)], 
            from:accounts[0], 
            value: web3.utils.toWei('1.0001','ether')}) 

        let release = await trigger.Balance();

        let balance = await web3.eth.getBalance(trigger.address);
        console.log(balance);
        console.log(trigger.address);




    })
    
})

// test abstract bank
contract(Abstract_Bank, accounts => {
    it("Launch Abstract Bank contract the Coinbank", async() =>  {
        let abstract = await Abstract_Bank.deployed();
        let bank = await abstract.Balance();
    })
})