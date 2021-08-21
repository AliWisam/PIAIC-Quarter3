// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract MyBank is Ownable {
    uint256 private totalBalance;
    address[] accounts;
    mapping(address => uint256) private balanceOfAccount;
    mapping(address => uint256) private initialDeposit;
    mapping(address => bool) private hasAccount;

    mapping(address => accountsCloseRequestsStruct) private accCloseMapping;
    address[] private reqAddrArr;
    struct accountsCloseRequestsStruct {
        bool accoutCloseRequest;
        string reason;
    }

    event ContractBalance(uint256 contractBalance);
    event BankClosed(string message);
    event AccountOpenedBy(address acc);
    event Deposit(uint256 bal);
    event WithdrewBy(address addr);
    event WithdrewValue(uint256 val);
    event BonusValue(uint256 bonusValue);
    event AccountCloseRequest(address addr, string reason);
    event AccountClosed(address addr);

    constructor() payable {
        require(
            msg.value >= 50 ether,
            "constructor: Initial deposit should be equal to greater than 50"
        );
        payable(address(this)).transfer(msg.value);
        totalBalance += msg.value;

        emit ContractBalance(totalBalance);
    }

    function closeBank() public onlyOwner returns (bool) {
        selfdestruct(payable(msg.sender));
        emit BankClosed("Transferred all balance to owner and bank is closed");
        return true;
    }

    function openNewAccount() public payable returns (bool) {
        require(
            hasAccount[msg.sender] == false,
            "You have already created your account"
        );
        require(
            msg.value >= 1 ether,
            "openNewAccount: Initial deposit should be equal to greater than 1"
        );
        totalBalance += msg.value;
        hasAccount[msg.sender] = true;
        initialDeposit[msg.sender] = msg.value;
        balanceOfAccount[msg.sender] += msg.value;
        accounts.push(msg.sender);

        emit AccountOpenedBy(msg.sender);
        emit Deposit(msg.value);
        emit ContractBalance(totalBalance);
        return true;
    }

    function getBalanceByAddress(address _addr)
        external
        view
        onlyOwner
        returns (uint256)
    {
        return balanceOfAccount[_addr];
    }

    function getBalanceUser() external view returns (uint256) {
        return balanceOfAccount[msg.sender];
    }

    function getBalanceByIndex(uint256 _index)
        external
        view
        onlyOwner
        returns (uint256)
    {
        return balanceOfAccount[accounts[_index]];
    }

    function depositEther() external payable returns (bool) {
        require(
            msg.value != 0,
            "msg.value should not be equal to zero, please send some ethers"
        );
        totalBalance += msg.value;
        balanceOfAccount[msg.sender] += msg.value;
        accounts.push(msg.sender);

        return true;
    }

    function withdrawEthers(uint256 _amount) external returns (bool) {
        require(
            hasAccount[msg.sender] == true,
            "you are not valid account holder"
        );
        require(
            _amount <= balanceOfAccount[msg.sender],
            "withdraw amount should be less then your balance"
        );
        totalBalance -= _amount;
        balanceOfAccount[msg.sender] -= _amount;
        emit WithdrewBy(msg.sender);
        emit WithdrewValue(_amount);
        return true;
    }

    function bonus() external onlyOwner {
        for (uint256 i = 0; i <= 4; i++) {
            payable(accounts[i]).transfer(1 ether);
            totalBalance -= 1 ether;
            balanceOfAccount[accounts[i]] += 1 ether;
        }
        emit BonusValue(1 ether);
    }

    function accountCloseRequest(string memory _reason)
        external
        returns (bool)
    {
        accCloseMapping[msg.sender].accoutCloseRequest = true;
        accCloseMapping[msg.sender].reason = _reason;
        reqAddrArr.push(msg.sender);

        emit AccountCloseRequest(
            msg.sender,
            accCloseMapping[msg.sender].reason
        );

        return true;
    }

    function getCloseRequestedAccounts()
        external
        view
        onlyOwner
        returns (address[] memory)
    {
        return reqAddrArr;
    }

    function closeAccount(address _add)
        external
        onlyOwner
        returns (bool success)
    {
        hasAccount[msg.sender] == false;

        payable(_add).transfer(balanceOfAccount[_add]);

        delete accCloseMapping[msg.sender];

        uint256 index = getIndexToDel(_add);

        for (uint256 i = index; i < reqAddrArr.length - 1; i++) {
            reqAddrArr[i] = reqAddrArr[i + 1];
        }
        reqAddrArr.pop();

        emit AccountClosed(_add);
        return true;
    }

    function getIndexToDel(address _add) internal view returns (uint256 index) {
        for (uint256 i = 0; i <= reqAddrArr.length; i++) {
            if (reqAddrArr[i] == _add) {
                return i;
            }
        }
    }

    function getAllAccounts()
        external
        view
        onlyOwner
        returns (address[] memory)
    {
        return accounts;
    }

    function getTotalBalance()
        external
        view
        onlyOwner
        returns (uint256, uint256 totalBalanceC)
    {
        return (totalBalance, address(this).balance);
    }
}
