pragma solidity ^0.5.1;

contract ImpactBlock {
    
    constructor (address _validator, address payable _ngo, address payable _investor) payable public {
    validator = _validator; 
    investor = _investor;
    ngo = _ngo;
    }
    
    address public validator; 
    address payable public ngo;  
    address payable public investor;   
    
    uint256 public Milestonecount=0;
    mapping  (uint => Milestone) public milestones;
    
    struct Milestone{
        uint _idMilestone;
        string description;
        uint KPI;
        uint cost;
        MilestoneStatus state; 
    }
    
    enum MilestoneStatus {
        Created,
        Accepted,
        Completed,
        Validated,
        Paid
    }
    
    MilestoneStatus state;
    
    /// EVENTS ////
    
    event MilestoneCreated();
    event MilestoneAccepted();
    event MilestoneCompletedAndWaitingForValidation();
    event MilestoneValidatedAndWaitingForPayment();
    event MilestonePaid();
    
    /// FUNCTIONS ///

    function addMilestone (string memory _description, uint _KPI, uint _cost) onlyNGO public 
    { Milestonecount +=1;
    milestones [Milestonecount]= Milestone(Milestonecount, _description, _KPI, _cost, MilestoneStatus.Created);
    }
    
    function acceptMilestone(uint _idMilestone) onlyInvestor public{

    require(milestones[_idMilestone].state == MilestoneStatus.Created);
    milestones[_idMilestone].state = MilestoneStatus.Accepted;
    emit MilestoneAccepted();
    }
    
    function requestValidationMilestone(uint _idMilestone) onlyNGO public{

    require(milestones[_idMilestone].state == MilestoneStatus.Accepted);
    milestones[_idMilestone].state = MilestoneStatus.Completed;
    emit MilestoneCompletedAndWaitingForValidation();
    }

    function validateMilestone(uint _idMilestone) onlyValidator public{

    require(milestones[_idMilestone].state == MilestoneStatus.Completed);
    milestones[_idMilestone].state = MilestoneStatus.Validated;
    emit MilestoneValidatedAndWaitingForPayment();
    
    }
 
    /// PAYMENT //////

    function payMilestone(uint _idMilestone) public payable onlyInvestor{
        require(milestones[_idMilestone].state == MilestoneStatus.Validated);
        ngo.transfer(address(this).balance);
        milestones[_idMilestone].state = MilestoneStatus.Paid;
        emit MilestonePaid();
    }
    
    ///////
    function changeValidator(address _newValidator)public onlyInvestor {
            validator = _newValidator;
        }
    
    modifier onlyValidator { require(msg.sender == validator); _; }
    modifier onlyNGO { require(msg.sender == ngo); _; }
    modifier onlyInvestor { require(msg.sender == investor); _; }
    
}