pragma solidity ^0.4.11;

import "./Verifier.sol";
import "./Verifiable.sol";

/*
 * @title Verifier contract that always returns true
 */
contract IdentityVerifier is Verifier {
    /*
     * @dev Verify implementation that always returns true. Used primarily for testing purposes
     * @param _jobId Job identifier
     * @param _segmentSequenceNumber Segment being verified for job
     * @param _code Swarm hash of binary to execute off-chain
     * @param _transcodedDataHash Swarm hash of transcoded input data of segment
     * @param _callbackContract Address of Verifiable contract to call back
     */
    function verify(uint256 _jobId, uint256 _segmentSequenceNumber, bytes32 _code, bytes32 _transcodedDataHash, address _callbackContract) external returns (bool) {
        // Check if receiveVerification on callback contract succeeded
        if (!Verifiable(_callbackContract).receiveVerification(_jobId, _segmentSequenceNumber, true)) throw;

        return true;
    }
}
