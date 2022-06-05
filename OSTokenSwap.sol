pragma solidity ^0.8.9;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract OSTokenSwap is Ownable, ReentrancyGuard {
    uint256 private balance;
    bool paused = false;
    mapping (address => uint) private balances;
    event TransferReceived(address _from, uint _amount);
    event TransferSent(address _from, address _destAddr, uint _amount);
    
    constructor() ReentrancyGuard()public{
        
    }
    
    receive() payable external {
        balance += msg.value;
        emit TransferReceived(msg.sender, msg.value);
    }    

            modifier isPaused {
            require(paused);
            _;
            }

            modifier notPaused {
            require(! paused);
            _;
            }

            function pauseContract() public onlyOwner notPaused {
                paused = true;
            }

            function unpauseContract() public onlyOwner isPaused {
                paused = false;
            }

    using SafeERC20 for IERC20;
    function WithdrawToken(IERC20 token, address to, uint256 amount) nonReentrant() notPaused() public {
        require(tx.origin == msg.sender);
        uint256 erc20balance = token.balanceOf(address(this));
        require(msg.sender.balance>=10000000000000000 ,"Not enough check balance");
        balances[msg.sender]=0;
        require(amount <= erc20balance, "balance is low");
        //Payer
        token.safeTransfer(to, amount);
        emit TransferSent(msg.sender, to, amount);
          
    }    
}
