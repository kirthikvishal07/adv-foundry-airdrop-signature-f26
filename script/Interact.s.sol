//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";


contract ClaimAirdrop is Script{
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 PROOF_ONE = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 PROOF_TWO = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] PROOF = [PROOF_ONE, PROOF_TWO];
    bytes private SIGNATURE = hex"448c7508ff80fb76810292af684c525c224becb058db9b12f3f33bdedc6683a9630418f67f83ef7b8be3f19da62c2b8c6e9413e6e3f2b405f578057f6f58b8c81c";
    
    error __ClaimAirdropScript_InvalidSignatureLength();

    function claimAirdrop(address airdrop) public{
        vm.startBroadcast();
        (uint8 v,bytes32 r,bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS,CLAIMING_AMOUNT,PROOF,v,r,s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if(sig.length != 65) {
            revert __ClaimAirdropScript_InvalidSignatureLength();
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

    }

    function run() public{
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }

    function getTemp() public view returns(uint256){
        return temp;
    }
}
 