pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {BoredApeTokens} from "./BAT.sol";


contract StakingRewards{

    IERC20 public stakingToken;
    IERC721 public BoredApeNFT;

    struct Account{
        uint currentStake;
        uint lastTimeStake;
        }
    mapping(address => Account) public AccountDetails;

    uint256 public rewardsDuration = 30 days;
    uint256 minimumPeriod = 3 days;
  
  using SafeMath for uint256;

//   address BoredApeNFT = 0xBC4CA0EDA7647A8Ab7C2061C2E118A18A936F13D;
  

    address[] internal stakeholders;

   
    mapping(address => uint256) internal stakes;

   
    mapping(address => uint256) internal rewards;

    event Staked (address _staker, uint _amount);

    
   constructor(address _stakingToken, address _BoredApeNFT) {
        stakingToken = IERC20(_stakingToken);
        BoredApeNFT = IERC721(_BoredApeNFT);
    }

    // ---------- STAKES ----------

    
    // A method for a stakeholder to create a stake.
    // _amount The size of the stake to be created.
    function stake(uint _amount) external {
      Account storage A = AccountDetails[msg.sender];
      require(BoredApeNFT.balanceOf(msg.sender)>= 1, "buy one bored ape to stake");
      require(_amount >= 5* 10**18, "You need  to stake > 5 BAT tokens");
      uint stakePeriod = block.timestamp - A.lastTimeStake;
      if (A.lastTimeStake==0){
        A.currentStake = _amount;
      }
      else {
        if(stakePeriod>= minimumPeriod){
        uint bonus = calculateReward(msg.sender);

        uint baseReward = stakePeriod * bonus;
        A.currentStake += baseReward + _amount;
        } else{
          A.currentStake += _amount;
        }
    }
        A.lastTimeStake = block.timestamp;
        if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
        stakes[msg.sender] += _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        emit Staked(msg.sender, _amount);

        }

    /**
     A method to retrieve the stake for a stakeholder.
     _stakeholder The stakeholder to retrieve the stake for.
     uint256 The amount of wei staked.
     */
    function stakeOf(address _stakeholder)
        public
        view
        returns(uint256)
    {
        return stakes[_stakeholder];
    }

    /**
      A method to the aggregated stakes from all stakeholders.
      uint256 The aggregated stakes from all stakeholders.
     */
    function totalStakes()
        public
        view
        returns(uint256)
    {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
        }
        return _totalStakes;
    }

    // ---------- STAKEHOLDERS ----------

    /**
      A method to check if an address is a stakeholder.
     _address The address to verify.
      bool, uint256 Whether the address is a stakeholder, 
     * and if so its position in the stakeholders array.
     */
    function isStakeholder(address _address)
        public
        view
        returns(bool, uint256)
    {
      require(BoredApeNFT.balanceOf(_address)>= 1, "buy one bored ape to stake");
      
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            if (_address == stakeholders[s]) return (true, s);
        }
        return (false, 0);
    }

    /**
      A method to add a stakeholder.
      _stakeholder The stakeholder to add.
     */
    function addStakeholder(address _stakeholder)
        public
    {
      require(BoredApeNFT.balanceOf(_stakeholder)>= 1, "buy one bored ape to stake");
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
    }

    /**
      A method to remove a stakeholder.
      _stakeholder The stakeholder to remove.
     */
    function removeStakeholder(address _stakeholder)
        public
    {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder){
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        } 
    }

    // ---------- REWARDS ----------
    
    
    function calculateReward(address _stakeholder)
        public
        view
        returns(uint256)
    {
     
    uint256 amount = stakes[_stakeholder] * 1e18;
        uint reward = (amount *10)/100;
        uint duration = 30;
        

       uint  modified = reward / duration;
       uint rewardPerSec = modified / 86400;
       return rewardPerSec; 
    }

    

    // function rewardview()public view returns (uint256){

    //     return rewardPerSec;

    // }

    /**
     * @notice A method to allow a stakeholder to withdraw his stake and rewards if entitled to any.
     */
    function withdraw(uint _amount) 
        public
    {
        require (stakes[msg.sender] == 0, "yooo you don't money in the contract");
        Account storage A = AccountDetails[msg.sender];
        uint stakePeriod = block.timestamp - A.lastTimeStake;
        if(stakePeriod >= minimumPeriod){
        uint bonus = calculateReward(msg.sender);

        uint baseReward = stakePeriod * bonus;
        A.currentStake += baseReward + _amount;
        } else{
          A.currentStake -= _amount;
        }
        stakingToken.transfer(msg.sender, _amount);
    }


}