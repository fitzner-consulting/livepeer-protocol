pragma solidity ^0.5.11;
// solium-disable-next-line
pragma experimental ABIEncoderV2;

import "./mixins/MixinContractRegistry.sol";
import "./mixins/MixinReserve.sol";
import "./mixins/MixinTicketBrokerCore.sol";
import "./mixins/MixinTicketProcessor.sol";
import "./mixins/MixinWrappers.sol";


contract TicketBroker is
    MixinContractRegistry,
    MixinReserve,
    MixinTicketBrokerCore,
    MixinTicketProcessor,
    MixinWrappers
{
    constructor(
        address _controller
    )
        public
        MixinContractRegistry(_controller)
        MixinReserve()
        MixinTicketBrokerCore()
        MixinTicketProcessor()
    {}

    /**
     * @notice Sets unlockPeriod value. Only callable by the Controller owner
     * @param _unlockPeriod Value for unlockPeriod
     */
    function setUnlockPeriod(uint256 _unlockPeriod) external onlyControllerOwner {
        unlockPeriod = _unlockPeriod;
    }

    /**
     * @notice Sets ticketValidityPeriod value. Only callable by the Controller owner
     * @param _ticketValidityPeriod Value for ticketValidityPeriod
     */
    function setTicketValidityPeriod(uint256 _ticketValidityPeriod) external onlyControllerOwner {
        require(_ticketValidityPeriod > 0, "ticketValidityPeriod must be greater than 0");

        ticketValidityPeriod = _ticketValidityPeriod;
    }
}