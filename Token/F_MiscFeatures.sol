pragma solidity ^0.4.19;

import './F_ICO.sol';

contract killable is ICO {
    
    function killContract() ownerOnly{
        selfdestruct(ownerAccount);
    }
}