pragma solidity ^0.4.19;
import './F_SafeMath.sol';

contract ERC20 {
    function totalSupply() constant returns (uint _totalSupply);
    function balanceOf(address _owner) constant returns (uint balance);
    function transfer(address _to, uint _value) returns (bool success);
    function transferFrom(address _from, address _to, uint _value) returns (bool success);
    function approve(address _spender, uint _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract BaseToken is ERC20 {
    
    address public owner;
    using SafeMath for uint256;
    
    bool public tokenStatus = false;
    
    modifier ownerOnly(){
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyWhenTokenIsOn(){
        require(tokenStatus == true);
        _;
    }

    function onOff () ownerOnly{
        tokenStatus = !tokenStatus;    
    }

    /**
       * @dev Fix for the ERC20 short address attack.
    */
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }    
    mapping (address => uint256) public balances;
    mapping(address => mapping(address => uint256)) allowed;

    //Token Details
    string public symbol = "BASE";
    string public name = "Base Token";
    uint8 public decimals = 18;

    uint256 public totalSupply; //will be instantiated in the derived Contracts
    
    function totalSupply() constant returns (uint256 ){
        return totalSupply;
    }

    function balanceOf(address _owner) constant returns (uint balance){
        return balances[_owner];
    }
    
    function transfer(address _to, uint _value) onlyWhenTokenIsOn onlyPayloadSize(2 * 32) returns (bool success){
        require(
            balances[msg.sender]>=_value 
            && _value > 0);
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender,_to,_value);
            return true;
    }
    
    function transferFrom(address _from, address _to, uint _value) onlyWhenTokenIsOn onlyPayloadSize(3 * 32) returns (bool success){
        //_value = _value.mul(10**decimals);
        require(
            allowed[_from][msg.sender]>= _value
            && balances[_from] >= _value
            && _value >0 
            );
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
            
    }
    
    function approve(address _spender, uint _value) onlyWhenTokenIsOn returns (bool success){
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) constant returns (uint remaining){
        return allowed[_owner][_spender];
    }
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}



