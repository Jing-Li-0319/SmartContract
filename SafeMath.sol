pragma solidity >=0.7.0 <0.9.0;

library SafeMath{
    function addition(uint a, uint b) public pure returns(uint){
        uint c = a + b;
        require(c >= a && c >= b);
        return c;
    }
    function subtraction(uint a, uint b) public pure returns(uint){
        require (a >= b);
        uint c = a - b;
        return c;
    }
    function division(uint a, uint b) public pure returns(uint){
        require (b > 0);
        uint c = a/b;
        return c;
    }
    function multiplication(uint a, uint b) public pure returns(uint){
        uint c = a * b;
        require (c >= a);
        return c;
    }
}