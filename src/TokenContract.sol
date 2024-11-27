// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// imports
import {ERC20, ERC20Burnable} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {AggregatorV3Interface} from
    "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

// contract
contract TokenContract is ERC20, Ownable, ERC20Burnable, ReentrancyGuard {
    // error
    error Token__CannotMintToZeroAddress();
    error Token__UnableToFetchPriceFeedData();
    error Token__MaxSupplyExceeded();
    error Token__MaxBalanceExceeded();

    // events
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event MaxBalancePerAddressUpdated(uint256 newMaxBalancePerAddress);

    // state variables
    AggregatorV3Interface internal s_priceFeed;
    uint256 public immutable i_maxSupply;
    uint256 public s_maxBalancePerAddress; // Max balance per address

    // constructor
    constructor(address _priceFeed) ERC20("Token", "TKN") Ownable(msg.sender) {
        s_priceFeed = AggregatorV3Interface(_priceFeed);
        i_maxSupply = 1_000_000 * 10 ** decimals();
        s_maxBalancePerAddress = 50_000 * 10 ** decimals();
        _mint(msg.sender, s_maxBalancePerAddress);
    }

    // functions
    function getLatestPrice() public view returns (int256) {
        (, int256 price,,,) = s_priceFeed.latestRoundData();
        if (price > 0) {
            return price / 10 ** 8;
        } else {
            revert Token__UnableToFetchPriceFeedData();
        }
    }

    // Allow owner to update max balance per address
    function updateMaxBalancePerAddress(uint256 _newMaxBalancePerAddress) external onlyOwner {
        s_maxBalancePerAddress = _newMaxBalancePerAddress;
        emit MaxBalancePerAddressUpdated(_newMaxBalancePerAddress);
    }

    // mint function
    function mint(address to, uint256 amount) external nonReentrant {
        if (to == address(0)) revert Token__CannotMintToZeroAddress();
        if (totalSupply() + amount > i_maxSupply) revert Token__MaxSupplyExceeded();
        if (balanceOf(to) + amount > s_maxBalancePerAddress) revert Token__MaxBalanceExceeded();

        _mint(to, amount);
        emit Mint(to, amount);
    }

    // burn function
    function burn(uint256 amount) public override nonReentrant {
        super.burn(amount);
        emit Burn(msg.sender, amount);
    }

    // check balance of an address
    function checkBalance(address account) external view returns (uint256) {
        return balanceOf(account);
    }
}
