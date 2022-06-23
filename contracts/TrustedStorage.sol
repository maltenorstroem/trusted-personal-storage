// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract TrustedStorage {

    struct Trust {
        address delegate;
        bytes[] data;
    }


    // This declares a state variable that
    // stores a `Trust` struct for each possible address.
    mapping(address => Trust) public trusts;


    constructor(bytes[] memory data) {
       trusts[msg.sender].data = data;
    }


    function delegate(address to) external {
        require(to != msg.sender, "Self-delegation is disallowed.");

        Trust storage sender = trusts[msg.sender];
        // Forward the delegation as long as
        // `to` also delegated.
        // In general, such loops are very dangerous,
        // because if they run too long, they might
        // need more gas than is available in a block.
        // In this case, the delegation will not be executed,
        // but in other situations, such loops might
        // cause a contract to get "stuck" completely.
        while (trusts[to].delegate != address(0)) {
            to = trusts[to].delegate;

            // We found a loop in the delegation, not allowed.
            require(to != msg.sender, "Found loop in delegation.");
        }

        Trust storage delegate_ = trusts[to];

    }


    function restore() external view returns (bytes[] memory)
    {
        return trusts[msg.sender].data;
    }
}
