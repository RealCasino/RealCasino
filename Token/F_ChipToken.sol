pragma solidity ^0.4.19;

import './F_ICO.sol';
import './F_MiscFeatures.sol';
import './F_Multiround.sol';

contract ChipToken is ICO,killable,MultiRound {
    
    uint256 constant alloc1perc=150;//in percent --Team & Founders
    address constant alloc1Acc = 0x7955ddec3E4c93c9668C381C6df19472D0559F3B;

    uint256 constant alloc2perc=50;//in percent -- Advisors
    address constant alloc2Acc = 0x2DFf8dF0640C12407f843483F97de2585cE90075;

    address constant ownerAccount = 0xEF94D48b312cb511D8520Be277367D0Dd71c33ad;
    mapping(address => uint) public blockedTill;    

    function ChipToken() {
        symbol = "CHIP";
        name = "CHIP TOKEN";
        decimals = 18;
        multiplier = base ** decimals;

        totalSupply = 4800000000 * multiplier; //4800 mn-- extra 18 zeroes are for the wallets which use decimal variable to show the balance 
        owner = msg.sender;

        balances[owner] = totalSupply;
        currentICOPhase = 1;
		uint256 limit80 = 3840000000 * multiplier; // This is when phase can consume all 80% of the public sale tokens
		uint256 date = toTimestamp(getYear(now), getMonth(now), getDay(now));
        addICOPhase("Private sale", limit80, 130000, date += 16 days); 
        addICOPhase("Pre-Sale 20%", limit80, 120000, date += 2 days);
        addICOPhase("Pre-Sale 15%", limit80, 115000, date += 2 days);
        addICOPhase("Pre-Sale 10%", limit80, 110000, date += 2 days);
        addICOPhase("Pre-Sale 7%", limit80, 107000, date += 2 days);
        addICOPhase("Pre-Sale 5%", limit80, 105000, date += 2 days);
        addICOPhase("Pre-Sale 3%", limit80, 103000, date += 2 days);
        addICOPhase("Pre-Sale 2%", limit80, 102000, date += 1 days);
        addICOPhase("Public Sale", limit80, 100000, date += 31 days);
        runAllocations();
    }

    function runAllocations() ownerOnly{
        balances[owner] = ((1000-(alloc1perc+alloc2perc)) * totalSupply)/1000;
        
        balances[alloc1Acc] = (alloc1perc * totalSupply)/1000;
        blockedTill[alloc1Acc] = toTimestamp(2018, 12, 25);
        
        balances[alloc2Acc] = (alloc2perc * totalSupply)/1000;
        blockedTill[alloc2Acc] = now;
    }

    function () payable {
        createTokens();
    }   
    
    function createTokens() payable {
        ICOPhase storage i = icoPhases[currentICOPhase]; 
        require(msg.value > 0 && i.saleOn == true);

        uint256 tokens = msg.value.mul(i.RATE);
		require(balances[owner] >= tokens);
		
        balances[owner] = balances[owner].sub(tokens);
        
        ownerAccount.transfer(msg.value);
        balances[msg.sender] = balances[msg.sender].add(tokens);
        i.tokensAllocated = i.tokensAllocated.add(tokens);

        ethContributedBy[msg.sender] = ethContributedBy[msg.sender].add(msg.value);
        totalEthRaised = totalEthRaised.add(msg.value);
        totalTokensSoldTillNow = totalTokensSoldTillNow.add(tokens);
		
		Emission(msg.sender, tokens, i.RATE);

        if(i.tokensAllocated>=i.tokensStaged || now>i.deadline ){
            i.saleOn = !i.saleOn; 
            currentICOPhase++;
        }
    }
    
    function transfer(address _to, uint _value) onlyWhenTokenIsOn onlyPayloadSize(2 * 32) returns (bool success){
        require(
            balances[msg.sender]>=_value 
            && _value > 0
            && now > blockedTill[msg.sender]
        );
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender,_to,_value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint _value) onlyWhenTokenIsOn onlyPayloadSize(3 * 32) returns (bool success){
        require(
            allowed[_from][msg.sender]>= _value
            && balances[_from] >= _value
            && _value >0 
            && now > blockedTill[_from]            
        );

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }
	
    function getBlockedTill(address _address) constant returns(uint256){
        return blockedTill[_address];
    }
	
	event Emission(address indexed _to, uint256 _value, uint256 _rate);
}


