/*
 * This exercise has been updated to use Solidity version 0.8.5
 * See the latest Solidity updates at
 * https://solidity.readthedocs.io/en/latest/080-breaking-changes.html
 */
// SPDX-License-Identifier: MIT
pragma solidity  >=0.5.16 <0.9.0;

contract SimpleBank {
  
    mapping (address => uint) private balances;
    mapping (address => bool) public enrolled;
    address public owner = msg.sender;
    
    event LogEnrolled(address indexed accountAddress);
    event LogDepositMade(address indexed accountAddress, uint amount);
    event LogWithdrawal(address indexed accountAddress, uint withdrawAmount, uint newBalance);

    fallback () external payable {
        revert();
    }

    receive() external payable {}

    /// @notice Get balance
    /// @return The balance of the user
    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    /// @notice Enroll a customer with the bank
    /// @return The users enrolled status
    // Emit the appropriate event
    function enroll() public returns (bool){
      if(enrolled[msg.sender] == true) {
        return false;
      }
      enrolled[msg.sender] = true; 
      emit LogEnrolled(msg.sender);
      return true;
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    function deposit() public payable returns (uint) {
      if(enrolled[msg.sender] == false) {
        this.enroll();
      }
      balances[msg.sender] = msg.value;
      emit LogDepositMade(msg.sender, msg.value);
      return balances[msg.sender];
    }

    /// @notice Withdraw ether from bank
    /// @dev This does not return any excess ether sent to it
    /// @param withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    function withdraw(uint withdrawAmount) public returns (uint) {
      require(balances[msg.sender] >= withdrawAmount, "Not enough found");
      balances[msg.sender] = balances[msg.sender] - withdrawAmount;
      address _to = msg.sender;

      (bool sent,) = _to.call{value: withdrawAmount}("");
      require(sent, "Failed to send Ether");

      emit LogWithdrawal(msg.sender, withdrawAmount, balances[msg.sender]);
      return balances[msg.sender];
    }
}
