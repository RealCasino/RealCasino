pragma solidity ^0.4.19;

import './F_BaseToken.sol';
import './F_DateTime.sol';

contract ICO is BaseToken,DateTimeEnabled{

    uint256 base = 10;
    uint256 multiplier;

    address ownerAccount;

    struct ICOPhase {
        string phaseName;
        uint256 tokensStaged;
        uint256 tokensAllocated;
        uint256 RATE;
        bool saleOn;
        uint deadline;
    }

    uint8 public currentICOPhase;
    
    mapping(address => uint256) public ethContributedBy;
    uint256 public totalEthRaised;
    uint256 public totalTokensSoldTillNow;

    mapping(uint8 => ICOPhase) public icoPhases;
    uint8 icoPhasesIndex = 1;
    
    function getEthContributedBy(address _address) constant returns(uint256){
        return ethContributedBy[_address];
    }

    function getTotalEthRaised() constant returns(uint256){
        return totalEthRaised;
    }

    function getTotalTokensSoldTillNow() constant returns(uint256){
        return totalTokensSoldTillNow;
    }
    
    function addICOPhase(string _phaseName, uint256 _tokensStaged, uint256 _rate,uint _deadline) ownerOnly{
        icoPhases[icoPhasesIndex].phaseName = _phaseName;
        icoPhases[icoPhasesIndex].tokensStaged = _tokensStaged;
        icoPhases[icoPhasesIndex].RATE = _rate;
        icoPhases[icoPhasesIndex].tokensAllocated = 0;
        icoPhases[icoPhasesIndex].saleOn = false;
        icoPhases[icoPhasesIndex].deadline = _deadline;
        icoPhasesIndex++;
    }

    function toggleSaleStatus() ownerOnly{
        icoPhases[currentICOPhase].saleOn = !icoPhases[currentICOPhase].saleOn;
    }
	
    function changeRate(uint256 _rate) ownerOnly{
        icoPhases[currentICOPhase].RATE = _rate;
    }
	
    function changeCurrentICOPhase(uint8 _newPhase) ownerOnly{ //Only provided for exception handling in case some faulty phase has been added by the owner using addICOPhase
        currentICOPhase = _newPhase;
    }

    function changeCurrentPhaseDeadline(uint256 _timestamp) ownerOnly{
        icoPhases[currentICOPhase].deadline = _timestamp; //sets deadline to timestamp
    }
	
    function changeCurrentPhaseLimit(uint256 _limit) ownerOnly{
        icoPhases[currentICOPhase].tokensStaged = _limit;
    }	
    
    function transferOwnership(address newOwner) ownerOnly{
        if (newOwner != address(0)) {
          owner = newOwner;
        }
    }
}
