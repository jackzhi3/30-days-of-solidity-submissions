// SPDX-License-Idantifier: MIT


pragma solidity ^0.8.0;

contract SAVE {        //别忘了定义一个合约先
  string name;         //string是定义一个字符串函数
  string commits;  

  function add(string memory _name, string memory _commits) public {  //这里的add（）里面有东西说明我们要进行输入
    name = _name;      //这里的下划线是给暂时储存的函数使用的               //memory 是为了将函数短暂储存
    commits = _commits;                                               //在括号里定义的函数只在函数里起作用
  }

  function retrieve()public view returns(string memory, string memory){//这里在函数上return是为了定义return出的函数类型
    return(name, commits);
  }

}