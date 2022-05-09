//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

//import openzeppelin contracts
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
//OWNABLE = functions that only owner can use
contract RoboPunksNFT is ERC721, Ownable{
    //storage variables 
    uint256 public mintPrice; 
    uint256 public totalSupply;
    uint256 public maxSupply;
    uint256 public maxPerWallet; 
    bool public isPublicMintEnabled;
    string internal baseTokenUri;
    address payable public withdrawWallet;
    mapping(address => uint256) public walletMints;

//constructor function is run on the first contract initialization
    constructor() payable ERC721('RoboPunks', 'RP'){
        mintPrice = 0.02 ether;
        totalSupply = 0; //start with zero
        maxSupply =1000;
        maxPerWallet = 3;
        //set withdraw wallet address
    }
        //from ownable contract, only the owner can call the function
    function setIsPublicMintEnabled(bool isPublicMintEnabled_) external onlyOwner{
        isPublicMintEnabled = isPublicMintEnabled_;
    }

    //uri of where the images are going to be locatied.
    function setBaseTokenUri(string calldata baseTokenUri_) external onlyOwner{
        baseTokenUri = baseTokenUri_;
    }
    //function to grab the images
    //override function, ensure you call the right variable
    function tokenURI(uint256 tokenId_) public view override returns(string memory){
        require(_exists(tokenId_), 'Token does not exist!'); //ensure that token id exist
        return string(abi.encodePacked(baseTokenUri, Strings.toString(tokenId_), ".json"));
        //allow openc to grab the uri for each images
    }
    //withdraw function, ensure only owner can use it
    function withdraw() external onlyOwner {
        //grabbing the wallet and pass the value of the address
        //the address is the contract above
        //we're grabbing the success value from this
        (bool success, ) = withdrawWallet.call{ value: address(this).balance}('');
        require(success, 'withdraw failed');
    }
    //payable function is anything that requires an ether transaction
    function mint(uint256 quantity_) public payable{
        //most valuable part of thhe contract
        require(isPublicMintEnabled, 'minting not enabled');
        require(msg.value == quantity_ *mintPrice, 'wrong Mint value');
        require(totalSupply + quantity_ <= maxSupply, 'sold out');
        require(walletMints[msg.sender] + quantity_ <= maxPerWallet, 'exceed max wallet');
        //keep track of the quantity of the wallet.
        
        //perform the mint
        for(uint256 i =0; i < quantity_; i++){
             //loop through 
             uint256 newTokenId = totalSupply +1; //keep track of the supplies tokenid
             totalSupply++;
             _safeMint(msg.sender, newTokenId); // pass in the token id
        }
        //safemint exist in erc721, we inherit it, we can use it.
        
    }

}
