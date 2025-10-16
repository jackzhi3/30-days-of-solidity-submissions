// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Etherpiggybank{
    //开局变量的设定
    address public mg;
    address [] member;
    mapping (address => uint256) public balance;
    mapping (address => bool) public isMember;
    //开局确定manager是谁
    constructor(){
        mg = msg.sender;
        member.push(msg.sender);
    }
    //赋予mg权利的函数
    modifier Onlymg(){
        require(msg.sender == mg,'Only mg can do'); //==才是用来判断的
        _;//让函数通过
    }
    //前期的权利函数
    modifier Onlyregistermember(){
        require (isMember[msg.sender],'Only registermember can do');//这里用bool函数判断，不直接用数组
        _;
    }
    //开始功能实现

    //1）实现mg添加用户功能
    function addmembers(address _member) public Onlymg{
        require(_member !=address(0),"invalid address");//记得要验证0地址
        require(_member !=msg.sender,"bank manager is already a member");
        require(!isMember[_member],"member already registered");


        member.push(_member);
        isMember[_member] = true;  //true 不是 ture

    }
    //实现member存钱功能
    function save(uint256 _amount) public Onlyregistermember{
        require (_amount > 0,'invalid amount' );//记得检查amount是否大于0
        balance[msg.sender] += _amount;      
    }

    //实现member取钱功能
    function withdraw(uint256 _amount) public  Onlyregistermember{
        require (_amount > 0,'invalid amount' );
        require (_amount <= balance[msg.sender],'Not enough');
        balance[msg.sender] -= _amount;
    }
    //查看存款功能，注意modifier（Onlyregistermember)函数的位置！！！
    function checkmoney(address _member) Onlyregistermember public view returns(uint256){
        return(balance[_member]);

    }

    //额外内容（真实连接钱包的交易）
    function depositeth()public payable Onlyregistermember{//payable是同意用eth交易
        require(msg.value >0,"invalid amount");
        balance[msg.sender] += msg.value;  //msg.value是你自己在钱包输入的eth数量
        //这个是真的在交易存款，payable和msg.value绑定



}
}