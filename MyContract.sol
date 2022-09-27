// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@api3/airnode-protocol-v1/contracts/dapis/DapiReader.sol";


contract BeaconReaderExample is DapiReader {
    constructor(address _dapiServer) DapiReader(_dapiServer) {}

    function readBeaconWithId(bytes32 beaconId)
        private
        view
        returns (int224 value, uint256 timestamp)
    {
        (value, timestamp) = IDapiServer(dapiServer).readDataFeedWithId(
            beaconId
        );
    }

    function readBeaconValueWithId(bytes32 beaconId)
        private
        view
        returns (int224 value)
    {
        value = IDapiServer(dapiServer).readDataFeedValueWithId(beaconId);
    }

    function beaconIdToReaderToWhitelistStatus(
        bytes32 beaconId,
        address reader
    )
        private
        view
        returns (uint64 expirationTimestamp, uint192 indefiniteWhitelistCount)
    {
        return
            IDapiServer(dapiServer).dataFeedIdToReaderToWhitelistStatus(
                beaconId,
                reader
            );
    }

    

    // Our functions goes here

    function someAnalysis(bytes32 coin1BeaconId, bytes32 coin2BeaconId)
        public
        view
        returns (string memory)
    {
      int224 coin1Value = readBeaconValueWithId(coin1BeaconId);  
      int224 coin2Value = readBeaconValueWithId(coin2BeaconId);

      if (coin1Value > coin2Value) {
          return "coin1higher";
      } else if (coin1Value == coin2Value) {
          return "equal";
      } else {
          return "coin2higher";
      }
    } 

    event AnalysisEvent(string analysisResult);
    uint256 ANALYSIS_COST = 0.05 ether;

    function makeAnalysis(bytes32 coin1BeaconId, bytes32 coin2BeaconId) external payable {

        // make sure this contract is whitelisted
        (uint64 expirationTs1, ) = beaconIdToReaderToWhitelistStatus(coin1BeaconId, address(this));
        (uint64 expirationTs2, ) = beaconIdToReaderToWhitelistStatus(coin2BeaconId, address(this));
        require(expirationTs1 > 0, "This contract is not whitelisted for coin1BeaconId!");
        require(expirationTs2 > 0, "This contract is not whitelisted for coin2BeaconId!");

        // make sure user send enough
        uint256 receivedAmount = msg.value;
        require(receivedAmount >= ANALYSIS_COST, "Need more than 0.05 ether!");

        // make analysis and emit
        string memory analysisResult = someAnalysis(coin1BeaconId, coin2BeaconId); 
        emit AnalysisEvent(analysisResult);
        // return extra currency to sender (user)
        (bool success, ) = msg.sender.call{value: receivedAmount - ANALYSIS_COST}("");
        require(success, "Failed to call!");
    } 
    
}
