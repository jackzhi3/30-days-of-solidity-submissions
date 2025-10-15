// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract AdminOnly {

    // -------------------------- 状态变量：存储合约核心数据 --------------------------
    address public owner; 
    // 管理员地址（公开可见）：存储拥有最高权限的账户地址，部署合约者默认成为管理员
    uint256 public treasureAmount; 
    // 资产总数量（公开可见）：记录合约中"treasure"（可理解为资金/资产）的总规模
    mapping(address => uint256) public withdrawalAllowance; 
    // 提取授权映射（公开可见）：键=用户地址，值=该用户可提取的资产额度，管理普通用户的提取权限
    mapping(address => bool) public hasWithdrawn; 
    // 提取状态映射（公开可见）：键=用户地址，值=是否已提取，防止普通用户重复提取


    // -------------------------- 构造函数：合约部署时初始化 --------------------------
    constructor() {
        owner = msg.sender; 
        // msg.sender = 当前调用者地址（此处是合约部署者），将部署者设为初始管理员
    }


    // -------------------------- 权限修饰符（modifier）：核心意义详解 --------------------------
    // modifier 是 Solidity 的特殊语法，本质是「代码复用工具」+「权限/条件检查统一入口」
    // 核心意义：
    // 1. 避免重复代码：如果多个函数需要相同的检查逻辑（如"仅管理员可操作"），无需在每个函数里写重复的 require
    // 2. 统一逻辑维护：若检查规则需要修改（如后续增加多管理员），只需改 modifier，无需逐个改函数
    // 3. 明确权限边界：函数声明时加 onlyOwner，一眼就能识别该函数的权限范围，提升代码可读性
    modifier onlyOwner() {
        // 统一检查逻辑：判断当前调用者是否为管理员（所有加 onlyOwner 的函数都会先执行这步）
        require(msg.sender == owner, "Access denied: Only the owner can perform this action");
        _; // 「占位符」：表示执行「被该修饰符修饰的函数本体代码」（权限通过后才会走到函数逻辑）
    }


    // -------------------------- 管理员专属函数：依赖 onlyOwner 实现权限控制 --------------------------
    // 1. 向合约添加资产（仅管理员）
    // 函数加 onlyOwner → 执行前先通过 modifier 检查权限，确保只有管理员能调用
    function addTreasure(uint256 amount) public onlyOwner {
        treasureAmount += amount; 
        // 资产总量 = 原总量 + 新增量，实现管理员向合约"存入"资产
    }

    // 2. 为普通用户授权提取额度（仅管理员）
    function approveWithdrawal(address recipient, uint256 amount) public onlyOwner {
        // 检查：授权额度不能超过合约现有资产总量，避免"超发授权"
        require(amount <= treasureAmount, "Not enough treasure available");
        withdrawalAllowance[recipient] = amount; 
        // 给目标用户（recipient）设置提取额度，普通用户需先授权才能提取
    }

    // 3. 重置普通用户提取状态（仅管理员）
    function resetWithdrawalStatus(address user) public onlyOwner {
        hasWithdrawn[user] = false; 
        // 将用户的提取状态从"已提取（true）"重置为"未提取（false）"，允许再次提取（需重新授权额度）
    }

    // 4. 转移管理员权限（仅管理员）
    function transferOwnership(address newOwner) public onlyOwner {
        // 检查：新管理员地址不能是"零地址"（无效地址），防止权限丢失
        require(newOwner != address(0), "Invalid address");
        owner = newOwner; 
        // 将管理员权限转移给新地址，原管理员失去权限
    }

    // 5. 查看资产总量（仅管理员，view修饰符：仅读不写，不消耗Gas）
    function getTreasureDetails() public view onlyOwner returns (uint256) {
        return treasureAmount; 
        // 返回当前合约资产总数量，供管理员查看资产规模
    }


    // -------------------------- 通用提取函数：管理员+普通用户均可调用（逻辑分支区分） --------------------------
    function withdrawTreasure(uint256 amount) public {
        // 分支1：若当前调用者是管理员（特殊逻辑：管理员可自由提取，无授权限制）
        if(msg.sender == owner){
            // 检查：管理员提取量不能超过资产总量，避免超提
            require(amount <= treasureAmount, "Not enough treasury available for this action.");
            treasureAmount -= amount; 
            // 资产总量 = 原总量 - 提取量，完成管理员提取
            return; 
            // 终止函数，不执行后续普通用户的逻辑（避免代码冗余）
        }

        // 分支2：若当前调用者是普通用户（需严格按授权规则提取）
        uint256 allowance = withdrawalAllowance[msg.sender]; 
        // 第一步：获取该用户的授权提取额度

        // 第二步：4重检查，确保普通用户提取合法
        require(allowance > 0, "You don't have any treasure allowance"); 
        // 检查1：用户有提取额度（未授权则报错）
        require(!hasWithdrawn[msg.sender], "You have already withdrawn your treasure"); 
        // 检查2：用户未提取过（已提取则报错，!表示取反：hasWithdrawn=false才通过）
        require(allowance <= treasureAmount, "Not enough treasure in the chest"); 
        // 检查3：授权额度不超过合约资产总量（防止合约资产不足）
        require(allowance >= amount, "Cannot withdraw more than you are allowed"); 
        // 检查4：用户提取量不超过授权额度（防止超额度提取）

        // 第三步：执行提取，更新合约状态
        hasWithdrawn[msg.sender] = true; 
        // 标记用户为"已提取"，禁止重复提取
        treasureAmount -= allowance; 
        // 资产总量减少"用户的授权额度"（示例中固定提取全部授权额度）
        withdrawalAllowance[msg.sender] = 0; 
        // 清空用户的授权额度，彻底关闭该用户的再次提取通道
    }
}