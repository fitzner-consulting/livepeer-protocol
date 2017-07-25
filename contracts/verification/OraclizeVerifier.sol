pragma solidity ^0.4.11;

import "./Verifier.sol";
import "./Verifiable.sol";

import "../../installed_contracts/oraclize/contracts/usingOraclize.sol";

/*
 * @title Verifier contract that uses Oraclize for off-chain computation
 */
contract OraclizeVerifier is Verifier, usingOraclize {
    // Stores parameters for an Oraclize query
    struct OraclizeQuery {
        uint256 jobId;
        uint256 segmentSequenceNumber;
        bytes32 transcodedDataHash;
        address callbackContract;
    }

    // Stores active Oraclize queries
    mapping (bytes32 => OraclizeQuery) oraclizeQueries;

    // Check if sender is Oraclize
    modifier onlyOraclize() {
        if (msg.sender != oraclize_cbAddress()) throw;
        _;
    }

    // Check if sufficient funds for Oraclize computation
    modifier sufficientOraclizeFunds() {
        if (oraclize_getPrice("computation") > this.balance) throw;
        _;
    }

    function OraclizeVerifier() {
        // OAR used for testing purposes
        OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
    }

    /*
     * @dev Verify implementation that creates an Oraclize computation query
     * @param _jobId Job identifier
     * @param _segmentSequenceNumber Segment being verified for job
     * @param _code Content-addressed storage hash of binary to execute off-chain
     * @param _dataHash Content-addressed storage hash of input data of segment
     * @param _transcodedDataHash Content-addressed storage hash of transcoded input data of segment
     * @param _callbackContract Address of Verifiable contract to call back
     */
    function verify(uint256 _jobId, uint256 _segmentSequenceNumber, bytes32 _code, bytes32 _dataHash, bytes32 _transcodedDataHash, address _callbackContract) payable sufficientOraclizeFunds external returns (bool) {
        // Create Oraclize query
        bytes32 queryId = oraclize_query("computation", [bytes32ToStr(_code), bytes32ToStr(_dataHash)]);

        // Store Oraclize query parameters
        oraclizeQueries[queryId].jobId = _jobId;
        oraclizeQueries[queryId].segmentSequenceNumber = _segmentSequenceNumber;
        oraclizeQueries[queryId].transcodedDataHash = _transcodedDataHash;
        oraclizeQueries[queryId].callbackContract = _callbackContract;

        return true;
    }

    /*
     * @dev Callback function invoked by Oraclize to return result of off-chain computation
     * @param _queryId Oraclize query identifier
     * @param _result Result of Oraclize computation
     */
    function __callback(bytes32 _queryId, string _result) onlyOraclize {
        OraclizeQuery memory oc = oraclizeQueries[_queryId];

        // Check if transcoded data hash returned by Oraclize matches originally submitted transcoded data hash
        if (oc.transcodedDataHash == strToBytes32(_result)) {
            // Notify callback contract of successful verification
            if (!Verifiable(oc.callbackContract).receiveVerification(oc.jobId, oc.segmentSequenceNumber, true)) throw;
        } else {
            // Notify callback contract of failed verification
            if (!Verifiable(oc.callbackContract).receiveVerification(oc.jobId, oc.segmentSequenceNumber, false)) throw;
        }

        // Remove Oraclize query
        delete oraclizeQueries[_queryId];
    }

    /*
     * @dev Convert a string to bytes32
     * @param _source Source string for conversion
     */
    function strToBytes32(string _source) public constant returns (bytes32) {
        // Check if string is 32 bytes
        if (bytes(_source).length != 32) throw;

        bytes32 result;

        // Load 32 bytes from source string
        assembly {
            result := mload(add(_source, 32))
        }

        return result;
    }

    /*
     * @dev Convert a bytes32 to a string
     * @param _source Source bytes32 for conversion
     */
    function bytes32ToStr(bytes32 _source) public constant returns (string) {
        bytes memory bytesStr = new bytes(32);

        uint256 charCount = 0;
        for (uint256 i = 0; i < 32; i++) {
            byte char = byte(bytes32(uint256(_source) * 2 ** (8 * i)));

            if (char != 0) {
                bytesStr[charCount] = char;
                charCount++;
            }
        }

        bytes memory bytesStrTrimmed = new bytes(charCount);
        for (i = 0; i < charCount; i++) {
            bytesStrTrimmed[i] = bytesStr[i];
        }

        return string(bytesStrTrimmed);
    }
}
