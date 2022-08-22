const { ethers } = require("hardhat")

module.exports=async({getNamedAccounts,deployments})=>{
    const{deployer}=await getNamedAccounts()
    const randomIpfsNft=await ethers.getContractAt("RandomIpfsNft",deployer)
    const randomIpfsMintTx=await randomIpfsNft.requestDoggie()
    const randomIpfsNftMintTxReceipt=await randomIpfsMintTx.wait(1)

}
module.exports.tags=["all","mint"]