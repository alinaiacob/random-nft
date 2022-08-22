//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
contract RandomIpfsNft is ERC721URIStorage,VRFConsumerBaseV2{
   VRFCoordinatorV2Interface immutable i_vrfCoordinator;

   bytes32 public immutable i_gasLane;
   uint64 public immutable i_subscriptionId;
   uint16 public constant REQUEST_CONFIRMATIONS=3;
   uint32 public immutable i_callbackGasLimit;
   uint32 public constant NUM_WORDS=3;
  string[3] public s_dogTokenUris;
   uint256 public constant MAX_CHANCE_VALUE=100;
   mapping(uint256=>address)s_requestIdToSender;
   uint256 s_tokenCounter;

   constructor(address vrfCoordinatorV2,bytes32 gasLane,uint64 subscriptionId,uint32 callbackGasLimit,string[3] memory dogTokenUris) 
         ERC721("Random Ipfs NFT","RIN") 
         VRFConsumerBaseV2(vrfCoordinatorV2)
         
         {
      i_vrfCoordinator=VRFCoordinatorV2Interface(vrfCoordinatorV2);
      i_gasLane=gasLane;
      i_subscriptionId=subscriptionId;
      i_callbackGasLimit=callbackGasLimit;
      s_dogTokenUris=dogTokenUris;
}
  
   function requestDoggie() public returns(uint256 requestId){
       requestId=i_vrfCoordinator.requestRandomWords(
        i_gasLane,//price per gas
        i_subscriptionId,
        REQUEST_CONFIRMATIONS,
        i_callbackGasLimit,//max gas amount
        NUM_WORDS
       );
       s_requestIdToSender[requestId]=msg.sender;
   }
   function fulfillRandomWords(uint256 requestId,uint256[] memory randomWords) internal override{
      //owner of the dog
      address dogOwner=s_requestIdToSender[requestId];
      //assign this NFT a tokenId
      uint256 newTokenId=s_tokenCounter;
      s_tokenCounter++;
      uint256 moddedRng=randomWords[0]%MAX_CHANCE_VALUE;
      uint256 breed=getBreedFromModdedRng(moddedRng);
      _safeMint(dogOwner, newTokenId);
      //set the TOKEN URI
      _setTokenURI(newTokenId,s_dogTokenUris[breed]);
   }
   function getChanceArray() public pure returns(uint256[3] memory){
    //0-9=st bernard
    //10-29 =pug
    //30-99=shiba
      return[10,30,MAX_CHANCE_VALUE];
   }
   function getBreedFromModdedRng(uint256 moddedRng) public pure returns(uint256){
     uint256 cumulativeSum=0;
     uint256[3] memory chanceArray=getChanceArray();
     for(uint256 i=0;i<chanceArray.length;i++){
        if(moddedRng>=cumulativeSum && moddedRng<cumulativeSum+chanceArray[i]){
            return i;
        }
        cumulativeSum+=chanceArray[i];
     }
   
   }  
}