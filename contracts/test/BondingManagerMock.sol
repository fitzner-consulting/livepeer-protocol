pragma solidity ^0.4.17;

import "../token/IMinter.sol";
import "../bonding/IBondingManager.sol";


/*
 * @title Mock BondingManager used for testing
 */
contract BondingManagerMock is IBondingManager {
    IMinter minter;

    address public transcoder;
    uint256 public pricePerSegment;
    uint256 public activeStake;
    uint256 public totalActiveStake;
    uint256 public withdrawAmount;

    function setMinter(address _minter) external {
        minter = IMinter(_minter);
    }

    function setActiveTranscoder(address _transcoder, uint256 _pricePerSegment, uint256 _activeStake, uint256 _totalActiveStake) external {
        transcoder = _transcoder;
        pricePerSegment = _pricePerSegment;
        activeStake = _activeStake;
        totalActiveStake = _totalActiveStake;
    }

    function setWithdrawAmount(uint256 _amount) external {
        withdrawAmount = _amount;
    }

    function withdraw() external {
        minter.transferTokens(msg.sender, withdrawAmount);
    }

    function reward() external {
        minter.createReward(activeStake, totalActiveStake);
    }

    function setActiveTranscoders() external returns (bool) {
        return true;
    }

    function updateTranscoderWithFees(address _transcoder, uint256 _fees, uint256 _round) external returns (bool) {
        return true;
    }

    function callAddToRedistributionPool(uint256 _amount) external {
        minter.addToRedistributionPool(_amount);
    }

    function slashTranscoder(address _transcoder, address _finder, uint64 _slashAmount, uint64 _finderFee) external returns (bool) {
        return true;
    }

    function electActiveTranscoder(uint256 _maxPricePerSegment, uint256 _block) external view returns (address) {
        return transcoder;
    }

    function transcoderTotalStake(address _transcoder) public view returns (uint256) {
        return activeStake;
    }

    function activeTranscoderTotalStake(address _transcoder) public view returns (uint256) {
        return activeStake;
    }
}
