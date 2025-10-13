// SPDX-License-Idantifier: MIT


pragma solidity ^0.8.0;

contract PollStation{
    string [] public voteName;//【】是一个数组（也就是列表）
    mapping (string => uint256) public voteCount;//mapping是为了使一个字符对应一个数字

    function addName(string memory _voteName) public {
        voteName.push(_voteName);//.push是为了给数组加数
    }
    
    function voteWho(string memory _voteName) public {
        voteCount[_voteName]++;//提取先前输入的字符对应的数字来运算
    }

    function getVoteCount(string memory _voteName) public view returns (uint256) {
        return voteCount[_voteName];
    }


}
    



