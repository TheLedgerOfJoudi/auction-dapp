pragma solidity  >=0.4.22 <0.8.0;
contract Auction {
    
    struct Item {
        uint itemId; 
        uint[] itemTokens;  
    }
    
    struct Person {
        uint remainingTokens; 
        uint personId; 
        address addr;
    }
 
    mapping(address => Person) tokenDetails; 
    Person [4] bidders;
    Item [3] public items;
    address public beneficiary;
    address [3] public winners;
    uint public bidderCount=0;
 
    constructor() public payable{    
        beneficiary = msg.sender;
        uint[] memory emptyArray;
        items[0] = Item({itemId:0,itemTokens:emptyArray});
        items[1] = Item({itemId:1,itemTokens:emptyArray}); 
        items[2] = Item({itemId:2,itemTokens:emptyArray});
    }
    
    function register() public payable{
        bidders[bidderCount].personId = bidderCount;
        bidders[bidderCount].addr = msg.sender;
        bidders[bidderCount].remainingTokens = 5; 
        tokenDetails[msg.sender]=bidders[bidderCount];
        bidderCount++;
    }
    
    function bid(uint _itemId, uint _count) public payable{
        if (tokenDetails[msg.sender].remainingTokens < _count || tokenDetails[msg.sender].remainingTokens==0) revert();
        if (_itemId > 2) revert();
        uint balance= tokenDetails[msg.sender].remainingTokens - _count; // TODO: use safemath
        tokenDetails[msg.sender].remainingTokens =balance;
        bidders[tokenDetails[msg.sender].personId].remainingTokens=balance;
        Item storage bidItem = items[_itemId];
        for(uint i=0; i<_count;i++) {
            bidItem.itemTokens.push(tokenDetails[msg.sender].personId);    
        }
    }
    
    modifier onlyOwner {
        require(msg.sender == beneficiary);
        _;
    }
    
    function revealWinners() public onlyOwner{
        // TODO: don't reveal winners until the auction is over
        for (uint id = 0; id < 3; id++) {
            Item storage currentItem=items[id];
            if(currentItem.itemTokens.length != 0){
            uint randomIndex = (block.number / currentItem.itemTokens.length)% currentItem.itemTokens.length; 
            uint winnerId = currentItem.itemTokens[randomIndex];
            winners[id] = bidders[winnerId].addr;
            }
        }
    } 

    function getPersonDetails(uint id) public view returns(uint,uint,address){
        return (bidders[id].remainingTokens,bidders[id].personId,bidders[id].addr);
    }

}
