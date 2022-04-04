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

        let trigger = await Abstract_Bank.at(CoinBank_Contract); 
        //---- payment
        //let account = accounts[0];
        console.log("Send funds");
        web3.eth.sendTransaction({
            to:trigger.address, 
            from:accounts[0], 
            value: web3.utils.toWei('19'),value:150000}) 

        let release = await trigger.Balance();
        var balance = await web3.eth.getBalance(trigger.address);
        //let balance = await web3.utils.fromWei(release,'ether');
        console.log("Print bank Balance");
        console.log(balance);  
        
        let actualBalance = await web3.utils.fromWei(accounts[0],'babbage');
        
        console.log("print test account");
        console.log(actualBalance);        //CoinBank_Contract
        
        //console.log(web3.utils.fromWei(balance, "ether"));
        //console.log(accounts[0].balance);
    })
})

// test abstract bank
contract(Abstract_Bank, accounts => {
    it("Launch Abstract Bank contract the Coinbank", async() =>  {
        let abstract = await Abstract_Bank.deployed();
        let bank = await abstract.Balance();
        assert(await abstract, "Abstract Coinbank Address Expected");
        //console.log(abstract.address);        //Abstract CoinBank_Contract
    })
})