pragma solidity ^0.7.3;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './CTokenInterface.sol';
import './ComptrollerInterface.sol';
import './PriceOracleInterface.sol';

contract MyDeFiProject {
	ComptrollerInterface public comptroller;
	PriceOracleInterface public priceOracle;

	constructor(address _comptroller, address _priceOracle) {
		comptroller = ComptrollerInterface(_comptroller);
		priceOracle = PriceOracleInterface(_priceOracle);
	}


	function supply(address cTokenaddress, uint underlyingAmount) external {
		CTokenInterface cToken = CTokenInterface(cTokenaddress);
		address underlyingAddress = cToken.underlying();
		IERC20(underlyingAddress).approve(cTokenaddress, underlyingAmount);

		uint result = cToken.mint(underlyingAmount);
		require(result == 0, 'cToken#mint() failed. see Compound ErrorReporter.sol');
	}


	function redeem(address cTokenaddress, uint cTokenAmount) external {
		CTokenInterface cToken = CTokenInterface(cTokenaddress);
		uint result = cToken.redeem(cTokenAmount);
		require(result == 0, 'cToken#redeem() failed. see Compound ErrorReporter.sol');
	}


	function enterMarket(address cTokenaddress) external {
		address[] memory markets = new address[](1);
		markets[0] = cTokenaddress;
		uint[] memory results = comptroller.enterMarkets(markets);
		require( results[0] == 0, 'comptroller#enterMarkets() failed. see Compound ErrorReporter.sol');
	}


	function borrow(address cTokenaddress, uint borrowAmount) external {
		CTokenInterface cToken = CTokenInterface(cTokenaddress);
		address underlyingAddress = cToken.underlying();
		uint result = cToken.borrow(borrowAmount);
		require(result == 0, 'cToken#borrow() failed. see Compound ErrorReporter.sol');

	}


	function repayBorrow(address cTokenaddress, uint underlyingAmount) external {
		CTokenInterface cToken = CTokenInterface(cTokenaddress);
		address underlyingAddress = cToken.underlying();
		IERC20(underlyingAddress).approve(cTokenaddress, underlyingAmount);
		uint result = cToken.repayBorrow(underlyingAmount);
		require(result == 0, 'cToken#repayborrow() failed. see Compound ErrorReporter.sol');
	}

	function getMaxBorrow(address cTokenaddress) external view returns(uint) {
		(uint result, uint liquidity, uint shortfall) = comptroller.getAccountLiquidity(address(this));
		require(result == 0, 'cToken#getAccountLiquidity() failed. see Compound ErrorReporter.sol');
		require(shortfall == 0, 'account underwater');
		require(liquidity > 0, 'account does not have liquidity');
		uint underlyingPrice = priceOracle.getUnderlyingPrice(cTokenaddress);
		return liquidity / underlyingPrice;
	}
}