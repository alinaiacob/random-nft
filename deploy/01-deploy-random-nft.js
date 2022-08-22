const{ethers,network}=require("hardhat")
module.exports=async({deployments,getNamedAccounts})=>{
    const{deploy,log}=deployments;
    const{deployer}=await getNamedAccounts();
    const chainId=network.config.chainId;
    const FUND_AMOUNT=ethers.utils.parseEther("0.1")
    let vrfCoordinatorV2Address,subscriptionId
    let tokenUris=[
        'ipfs://Qmcz47dLfyquXsPv1KV69i4jrHLqVLdgdtAZ39Pwj9Zuec',
        'ipfs://QmfM78xuxRXuxzznwrxGf4Z5w7vZqCpKPTa8L7oexcPotE',
        'ipfs://QmeC4r5YNuN6Xg24XSsZGdMy4D2GkXLXaSLkUsygGMBcfX'
      ];
    if(chainId==31337){
        //make a  fake chainlink VRF node
        const vrfCoordinatorV2Mock=await ethers.getContract("VRFCoordinatorV2Mock")
        vrfCoordinatorV2Address=vrfCoordinatorV2Mock.address;
        const tx=await vrfCoordinatorV2Mock.createSubscription()
        const txReceipt=await tx.wait(1)
        subscriptionId=await txReceipt.events[0].args.subId;
        await vrfCoordinatorV2Mock.fundSubscription(subscriptionId,FUND_AMOUNT)

    }else{
        //use the real ones
        vrfCoordinatorV2Address="0x6168499c0cFfCaCD319c818142124B7A15E857ab"
        subscriptionId='16606'

    }
    args=[
        vrfCoordinatorV2Address,
        "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",//gasLane
        subscriptionId,
        "500000",
        tokenUris
        //list of dogs
    ]
    const randomIpfsNft=await deploy("RandomIpfsNft",{
        from:deployer,
        log:true,
        args:args
    })
    
}
module.exports.tags=["all","randomipfsnft"]