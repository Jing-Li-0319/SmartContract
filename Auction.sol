pragma solidity ^0.8.0;

contract Creator{
    Auction[] public auctionList;

    function createAuction() public {
        Auction auction = new Auction(msg.sender);
        auctionList.push(auction);
    }
}

contract Auction{

    address payable public owner;
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;

    enum State{Started, Running, Ended, Canceled}
    State public auctionState;

    uint public highestBindingBid;
    address payable public highestBidder;

    mapping (address => uint) public bids;
    uint bidIncrement;

    constructor(address EOA) public {
        owner = payable (EOA);
        auctionState = State.Running;
        startBlock = block.number;
        endBlock = startBlock + 40320; // running time;
        ipfsHash = "";
        bidIncrement = 100;
    }
    
    modifier onlyOwner(){
        require (msg.sender == owner);
        _;
    }
    modifier notOwner(){
        require (msg.sender != owner);
        _;
    } 

    modifier afterStart(){
        require (block.number >= startBlock);
        _;
    }

    modifier beforeEnd(){
        require (block.number <= endBlock);
        _;
    }

    receive() external payable {
        bid();
    }
    fallback() external payable {}

    function cancelAuction() public onlyOwner afterStart beforeEnd{
        require (auctionState == State.Running,"The auction is not running!");
        auctionState = State.Canceled;
    }

    function bid() public payable notOwner afterStart beforeEnd returns (bool){
        require (auctionState == State.Running, "The auction is not running!");
        require (msg.value >= 100,"Not enough ether!");

        uint currentBid = bids[msg.sender] + msg.value;
        bids[msg.sender] = currentBid;

        require (currentBid > highestBindingBid);
        if (currentBid <= bids[highestBidder]){
            highestBindingBid = Min(currentBid + bidIncrement, bids[highestBidder]);
        }
        else {
            highestBindingBid = Min(currentBid, bids[highestBidder] + bidIncrement);
            highestBidder = payable(msg.sender);
        }
        return true;

    }
    
    //withdraw funds
    function finalizeAuction() public payable {
        require (auctionState == State.Canceled || block.number > endBlock);
        require (msg.sender == owner || bids[msg.sender] > 0, "Not the authorized auction participant!");
        uint amount;
        if (auctionState == State.Canceled){
            amount = bids[msg.sender]; // no winner
        }
        // auction is ended;
        else{
            if (highestBidder == msg.sender){ 
                amount = bids[msg.sender] - highestBindingBid;
            }
            else{
                amount = bids[msg.sender];// not win the auction
            }
        
        }
        
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);




        
    }



    function Min(uint a, uint b) private pure returns (uint){
        if (a<=b)
            return a;
        return b;
    }


    
}