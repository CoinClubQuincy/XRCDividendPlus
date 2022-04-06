const Plus = artifacts.require("Plus");
const Abstract_Bank = artifacts.require("CoinBank");

//test Treasury
contract(Plus, accounts => {
    it("Launch Plus contract and Coinbank", async() =>  {
        let instance = await Plus.deployed("Q-Shards","QSHD",100,18);
        let CoinBank_Contract = await instance.Get_CoinBank();
        assert(await CoinBank_Contract, "Coinbank Address Expected");
        
        console.log("tresury address");
        console.log(instance.address);           //Treasury
        var Tbalance = await web3.eth.getBalance(instance.address);
        console.log(Tbalance);

        let trigger = await Abstract_Bank.at(CoinBank_Contract); 
        //---- payment
        //let account = accounts[0];
        console.log("Send funds");
        web3.eth.sendTransaction({
            to:trigger.address, 
            from:accounts[0], 
            value: web3.utils.toWei('1'),value:"15000000"}) 

        let release = await trigger.Balance();
        var balance = await web3.eth.getBalance(trigger.address);
        
        console.log("Print bank Balance");
        console.log(balance);  
        
        //let actualBalance = await web3.utils.fromWei(accounts[0],'babbage');
        
        //console.log("print test account");
        //console.log(actualBalance);        //CoinBank_Contract
        
        console.log("Treasury Balance");
        newTBalance =  await web3.eth.getBalance(instance.address);
        console.log(newTBalance);
        
        //console.log(web3.utils.fromWei(balance, "ether"));
        //console.log(accounts[0].balance);
    })
})
contract(Plus, accounts => {
    it("Launch Plus contract and Coinbank", async() =>  {
        let instance = await Plus.deployed("Q-Shards","QSHD",100,18);
        let CoinBank_Contract = await instance.Get_CoinBank();
        assert(await CoinBank_Contract, "Coinbank Address Expected");
        
        console.log("tresury address");
        console.log(instance.address);           //Treasury
        var Tbalance = await web3.eth.getBalance(instance.address);
        //console.log(Tbalance);

    })
})