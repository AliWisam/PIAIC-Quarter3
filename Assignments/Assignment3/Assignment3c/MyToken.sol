// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract MyToken is ERC20Capped, Ownable, AccessControl {
    using SafeMath for uint256;

    bytes32 public constant PRICE_CHANGE_ROLE = keccak256("PRICE_CHANGE_ROLE");

    // timestamp when token release is enabled
    uint256 private immutable _releaseTime;

    uint256 price; // the price, in wei, per token

    event TokenValue(uint256 withDecimals, uint256 withoutDecimals);

    constructor(
        string memory name,
        string memory symbol,
        uint256 cap,
        uint256 _price
    ) ERC20(name, symbol) ERC20Capped(cap) {
        price = _price;
        _releaseTime = block.timestamp + 30 days;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PRICE_CHANGE_ROLE, msg.sender);
    }

    // This function is called for all messages sent to
    // this contract, except plain Ether transfers
    // (there is no other function except the receive function).
    // Any call with non-empty calldata to this contract will execute
    // the fallback function (even if Ether is sent along with the call).
    fallback() external payable {
        buyTokens();
    }

    function buyTokens() public payable returns (uint256) {
        require(msg.value != 0, "Value shouldn't be equal to zero");
        uint256 scaledAmount = msg.value.mul(10**decimals()).div(price);
        _mint(msg.sender, scaledAmount);
        emit TokenValue(scaledAmount, scaledAmount.div(10**decimals()));
        return scaledAmount;
    }

    /**
     * @return the time when the tokens are released.
     */
    function releaseTime() public view virtual returns (uint256) {
        return _releaseTime;
    }

    function mint(uint256 _amount) internal {
        _mint(owner(), _amount);
    }

    function changePrice(uint256 _price)
        public
        onlyRole(PRICE_CHANGE_ROLE)
        returns (uint256)
    {
        price = _price;
        return price;
    }

    function transfer(address recepient, uint256 amount)
        public
        override
        returns (bool)
    {
        require(
            block.timestamp >= releaseTime(),
            "TokenTimelock: current time is before release time"
        );
        super._transfer(msg.sender, recepient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recepient,
        uint256 amount
    ) public override onlyRole(PRICE_CHANGE_ROLE) returns (bool) {
        require(
            block.timestamp >= releaseTime(),
            "TokenTimelock: current time is before release time"
        );
        super._transfer(sender, recepient, amount);
        return true;
    }

    function sellToken(uint256 _tokenAmount) external returns (uint256) {
        require(
            transfer(owner(), _tokenAmount) == true,
            "Error in Token Transfer"
        );
        uint256 scaledAmount = _tokenAmount.div(price);
        payable(msg.sender).transfer(scaledAmount * 1 ether);
        return scaledAmount * 1 ether;
    }

    // This function is called for plain Ether transfers, i.e.
    // for every call with empty calldata.
    receive() external payable {}
}
