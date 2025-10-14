// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Auction {

    address  public  Owner;
    string public  Item;
    uint256  public AuctionandTime;

    address private highestBidder;
    uint256 private  highestBid;

    bool public ended;  //bool的值只有ture和false
    mapping (address=>uint256) public bids;
     address[ ] public  bidders;

     constructor (string memory _Item, uint256 _biddingTime) {
        Owner=msg.sender;
        Item = _Item;
        AuctionandTime  = block.timestamp+_biddingTime;
        //constructor在部署合约之前就要求填写的函数


     }

     function bid( uint256 amount) external {  //external是外部函数，而public可以在整个合约中被调用
        require(block.timestamp >AuctionandTime,"Auction already ended ");
        require(amount  > 0,"Bid amount is greater than zero");
        require(amount> bids [msg.sender],"Bid must be higher than your previous");

        if (bids [msg.sender]==0) { //msg.sender即当前调用该函数的用户地址

            bidders.push(msg.sender);
            bids [msg.sender]=amount;
        }
        if (amount >highestBid) {
            highestBid= amount;
            highestBidder=msg.sender;
        }

        

        }


        //require是一个内置函数 ，主要用于检查条件是否满足，起到输入验证和错误处理的作用
        //require 的核心逻辑就是必须让检查的条件成立（结果为 true），才会继续执行后续的代码；
        //如果条件不成立（结果为 false），整个函数会直接终止，后续代码不会执行。
        function endAuction () external {
            require(block.timestamp>=AuctionandTime," Auction has not endedyet");
            require(!ended,"Auction end has already been called");//！是false的意思
            ended = true;

        }

        function getwinner ()  external  view returns  ( address, uint256) {
            require(ended,"Auction has not ended");
            return (highestBidder,highestBid);


        }

        function getAllBidders () external  view  returns (address [] memory) {
            return  bidders;
        }

        
      }

