pragma solidity ^0.4.19;

import './F_ICO.sol';

contract MultiRound is ICO{
	
    function newICORound(uint256 _newSupply) ownerOnly {
        balances[owner] = balances[owner].add(_newSupply);
        totalSupply = totalSupply.add(_newSupply);
    }

    function destroyUnsoldTokens(uint256 _tokens) ownerOnly{
        totalSupply = totalSupply.sub(_tokens);
        balances[owner] = balances[owner].sub(_tokens);
    }
}