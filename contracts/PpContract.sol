// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./harvestLossLibrary.sol";
import "./calculateBaseLibrary.sol";
import "./sqrtLibrary.sol";
import "./issueCoinCompLibrary.sol";
import "./weightVoteLibrary.sol";

contract PpContract is ERC20 {
    
    using calculateBaseLibrary for *;
    using sqrtLibrary for *;
    using harvestLossLibrary for *;
    
    //Initial constructor for the entire Pricing Protocol contract
    constructor(uint256 initialSupply) ERC20("PricingCoin", "PP") {
        _mint(msg.sender, initialSupply);
        nonce = 1;
    }
    
    // ============ Mutable storage ============
    //tracks total profit generated during life of protocol
    uint profitGenerated;
    //tracks total amount of coins generated during life of protocol
    uint totalCoinsIssued;
    //
    uint nftsPriced;
    //tracks the current nonce (i.e. number lossPoolDistribution session)
    uint nonce;
    
    //Total amount of NFTs that have been priced using pricing protocol
    NftInformation[] public listOfNfts;
    //Keep track of all unique coin holder addresses 
    address[] coinHolders; 
    
    // ============ Mappings ============
    //Mapping to check if a user is already considered a coin holder
    mapping(address => bool) isCoinHolder;
    //Maps the total appraisal value to an NFT address to be used for mapping finalAppraisal to specific NFT address
    mapping(address => mapping(uint => uint)) totalAppraisalValue;
    //Mapping used to track how many voters have voted on a particular NFT
    mapping(address => mapping(uint => address[])) addressesPerNft;
    //Easily accesible pricing session lookup 
    mapping(address => mapping(uint => PricingSession)) AllPricingSessions;
    //Allows pricing protocol to handle multiple NFTs at once by allowing lookup and tracking of different NFTs
    mapping(address => mapping(uint => mapping (address => Voter))) nftVotes;
    //Allow contract to track which NFT sessions a user has participated in
    mapping(address => NftInformation[]) userSessionsParticipated;
    //Used to limit user lossPool claims to 1 per rounds
    mapping(uint => mapping(address => bool)) lossPoolAccessCheck;
    //Used to track start time of distribution session 
    mapping(uint => uint) lPDSstartTime;
    //
    mapping(uint => DistributeSession) lossPoolDistributionSession;
    
    // ============ Structs ============
    //Voter struct to allow users to submit votes, stake, and track that the user has already voted (i.e. exists = true) 
    struct Voter {
        /*
        Base --> base amount of tokens that equation for distibution will be based on. 
        Detemined by raw appraisal accuracy
        */
        uint base;
        //Voter appraisal 
        uint appraisal;
        //Voter stake
        uint stake;
        //Used to stop voters from entering multiple times from same address
        bool exists;
    }
    
    //Keeps track of important data from each pricing session in the form of an item
    struct PricingSession {
        //Sesssion start time
        uint startTime;
        //Session end time is 1 day after start time
        uint endTime;
        //Final appraisal calculated using --> weight per user * appraisal per user
        uint finalAppraisal;
        //Keep track of amount of unique voters (by address) in pricing session
        uint uniqueVoters;
        //Keep track of totalVotes (takes into account multiple votes attributed during weighting)
        uint totalVotes;
        //Track the amount of tokens issued in each pricing session
        uint tokensIssued;
        //Tracks lossPoolTotal in each pricing session
        uint lossPoolTotal;
        //Tracks total session stake
        uint totalSessionStake;
        //Track lowest stake, for vote weighting
        uint lowestStake;
        //Track amount of votes that have been weighted
        uint amountVotesWeighted;
        //Track amount of bases calculated
        uint amountBasesCalculated;
        //track amount of coin issue events 
        uint coinIssueEvents;
        //track amount of loss harvest events
        uint lossHarvestEvents;
        //Track existence of NFT session
        bool active;
        //Bools to force specific progression of actions and allow users to call functions
        bool votesWeighted;
        bool finalAppraisalSet;
        bool baseCalculated;
        bool coinsIssued;
        bool lossHarvested;
    }

    struct DistributeSession {
        uint poolSize; 
        uint PpToClaim;
        bool active;
    }

    struct NftInformation {
        address nftAddress;
        uint tokenid;
    }
    
    // ============ Events ============
    //Emit sessino creation event
    event sessionCreated(uint startTime, uint endTime, address _nftAddress, uint tokenid);
    //Represents a new vote being created
    event newVoteCreated(address _nftAddress, uint tokenid, address _voterAddress, uint appraisal, uint stake);
    //Event to show that a session ended.
    event sessionOver(address _nftAddress, uint tokenid, uint endTime);
    //Represents the ending of pricing session and a final appraisal being determined 
    event finalAppraisalDetermined(address _nftAddress, uint tokenid, uint appraisal, uint amountVoters);
    //Log coins being issued to user
    event coinsIssued(uint _amount, address recipient);
    //Log stakes successfully being refunded
    event stakeRefunded(uint _amount, address recipient);
    //Log lossPool successfully being distributed
    event lossPoolDistributed(uint _amount, address recipient);
    
    // ============ Modifiers ============
    //Check if contract is still currently active 
    modifier isActive(address _nftAddress, uint tokenid) {
        //If block.timestamp is less than endTime the session is over so user shouldn't be able to vote anymore
        require(block.timestamp < AllPricingSessions[_nftAddress][tokenid].endTime, "PNA");
        _;
    }
    
    //Enforce session buffer to stop sessions from getting overwritten
    modifier stopOverwrite(address _nftAddress, uint tokenid) {
        require(AllPricingSessions[_nftAddress][tokenid].active = false 
            && block.timestamp > AllPricingSessions[_nftAddress][tokenid].endTime + 10 days, "W8D");
        _;
    }
    
    //Make sure users don't submit more than one appraisal
    modifier oneVoteEach(address _nftAddress, uint tokenid) {
        require(!nftVotes[_nftAddress][tokenid][msg.sender].exists, "1V");
        _;
    }
    
    //Check to see that the user has enough money to stake what they promise
    modifier checkStake {
        require(msg.value >= 0.001 ether, "SETH");
        _;
    }
    
    //The following 7 modifiers enforce the proper progression of a session 
    modifier votingSessionComplete(address _nftAddress, uint tokenid) {
        require(block.timestamp >= AllPricingSessions[_nftAddress][tokenid].endTime, "PSO");
        _;
    }
    
    modifier votesWeightedComplete(address _nftAddress, uint tokenid) {
        require(AllPricingSessions[_nftAddress][tokenid].votesWeighted == true || 
            block.timestamp > AllPricingSessions[_nftAddress][tokenid].endTime + 1 days, "WVW"); 
        _;
    }
    
    modifier finalAppraisalComplete(address _nftAddress, uint tokenid) {
        require(AllPricingSessions[_nftAddress][tokenid].finalAppraisalSet == true, "WFA");
        _;
    }

    modifier baseCalculatedComplete(address _nftAddress, uint tokenid) {
        require(AllPricingSessions[_nftAddress][tokenid].baseCalculated == true ||
            block.timestamp > AllPricingSessions[_nftAddress][tokenid].endTime + 2 days, "WBC");
        _;
    }
    
    modifier coinsIssuedComplete(address _nftAddress, uint tokenid) {
        require(AllPricingSessions[_nftAddress][tokenid].coinsIssued == true ||
            block.timestamp > AllPricingSessions[_nftAddress][tokenid].endTime + 4 days, "WCI");
        _;
    }

    modifier lossHarvestedComplete(address _nftAddress, uint tokenid) {
        require(AllPricingSessions[_nftAddress][tokenid].lossHarvested == true ||
            block.timestamp > AllPricingSessions[_nftAddress][tokenid].endTime + 6 days, "WLH");
        _;
    }
    
    modifier checkSessionActive(address _nftAddress, uint tokenid) {
        require(AllPricingSessions[_nftAddress][tokenid].active = true);
        _;
    }
    
    //Create a new pricing session
    function createPricingSession(address _nftAddress, uint tokenid) stopOverwrite(_nftAddress, tokenid) public {
        //Create new instance of PricingSession
        PricingSession memory newSession;
        //Assign new instance to NFT address
        AllPricingSessions[_nftAddress][tokenid] = newSession;
        //Set start time of pricing session
        AllPricingSessions[_nftAddress][tokenid].startTime = block.timestamp;
        //Set end time of pricing session
        AllPricingSessions[_nftAddress][tokenid].endTime = block.timestamp + 1 days;
        //Set initial super high lowest stake so its inevitably overwritten
        AllPricingSessions[_nftAddress][tokenid].lowestStake = 10000000 ether;
        //Switch pricing session to active 
        AllPricingSessions[_nftAddress][tokenid].active = true;
        //Add new NFT address to list of addresses 
        listOfNfts.push(NftInformation(_nftAddress, tokenid));
        emit sessionCreated(block.timestamp, block.timestamp + 1 days, _nftAddress, tokenid);
    }
    
    /* 
    This function allows users to create a new vote for an NFT. 
    */
    function setVote(uint _appraisal, address _nftAddress, uint tokenid) checkStake isActive(_nftAddress, tokenid) oneVoteEach(_nftAddress, tokenid) payable public {
        //Create a new Voter instance
        Voter memory newVote = Voter(0, _appraisal, msg.value, true);
        if (msg.value < AllPricingSessions[_nftAddress][tokenid].lowestStake) {
            AllPricingSessions[_nftAddress][tokenid].lowestStake = msg.value;
        }
        //Add to total appraisal value for final appraisal calculation
        totalAppraisalValue[_nftAddress][tokenid] += _appraisal;
        AllPricingSessions[_nftAddress][tokenid].totalVotes ++;
        //Add to total session stake to for reward purposes later on in issueCoin equation
        AllPricingSessions[_nftAddress][tokenid].totalSessionStake += msg.value;
        //Attach new msg.sender address to newVote (i.e. new Voter struct)
        nftVotes[_nftAddress][tokenid][msg.sender] = newVote;
        //Add voter to addressesPerNft for tracking unique voters
        addressesPerNft[_nftAddress][tokenid].push(msg.sender);
        //Update sessions participated for user look up ability
        userSessionsParticipated[msg.sender].push(NftInformation(_nftAddress, tokenid));
        emit newVoteCreated(_nftAddress, tokenid, msg.sender, _appraisal, msg.value);
    }
    
     /* 
    Each vote is weighted based on the lowest stake. So lowest stake starts as 1 vote 
    and the rest of the votes are weighted as a multiple of that. Eq --> sqrt(stake/lowestStake)
    */
    function weightVote(address _nftAddress, uint tokenid) votingSessionComplete(_nftAddress, tokenid) public {
        if(block.timestamp > AllPricingSessions[_nftAddress][tokenid].endTime + 1 days) {
            AllPricingSessions[_nftAddress][tokenid].votesWeighted = true;
        }
        require(AllPricingSessions[_nftAddress][tokenid].votesWeighted == false);
        //Weighting user at <address a> vote based on lowestStake
        uint weight = sqrtLibrary.sqrt(nftVotes[_nftAddress][tokenid][msg.sender].stake/AllPricingSessions[_nftAddress][tokenid].lowestStake);
        //Add weighted amount of votes to PricingSession total votes for calculating setFinalAppraisal
        AllPricingSessions[_nftAddress][tokenid].totalVotes += weight-1;
        //weight - 1 since one instance was already added in initial setVote function
        totalAppraisalValue[_nftAddress][tokenid] += (weight-1) * nftVotes[_nftAddress][tokenid][msg.sender].appraisal;
        //Track to end session
        AllPricingSessions[_nftAddress][tokenid].amountVotesWeighted ++;
        if (AllPricingSessions[_nftAddress][tokenid].amountVotesWeighted == addressesPerNft[_nftAddress][tokenid].length){
            AllPricingSessions[_nftAddress][tokenid].votesWeighted = true;
        }
        else {
            AllPricingSessions[_nftAddress][tokenid].votesWeighted = false;
        }
    }
    
    /*
    Function used to set the final appraisal of a pricing session
    */
    function setFinalAppraisal(address _nftAddress, uint tokenid) votesWeightedComplete(_nftAddress, tokenid) public {
        //requires that the finalAppraisal has not been set yet
        require(AllPricingSessions[_nftAddress][tokenid].finalAppraisalSet == false);
        //If a session is larger than 25 people, the user that triggers the final Appraisal is awarded 2 * fourth-rt(session size) tokens.
        uint amount;
        if (addressesPerNft[_nftAddress][tokenid].length < 25) {
            amount = 0;
        }
        else {
            amount = 2 * sqrtLibrary.sqrt(sqrtLibrary.sqrt(addressesPerNft[_nftAddress][tokenid].length));
        }
        _mint(payable(msg.sender), amount);
        //Set amountOfVoters for tracking unique voters in a pricing session
        AllPricingSessions[_nftAddress][tokenid].uniqueVoters = addressesPerNft[_nftAddress][tokenid].length;
        //Set finalAppraisal by calculating totalAppraisalValue / totalVotes. Scale back the 1000 to make up for scaling method in setVote
        AllPricingSessions[_nftAddress][tokenid].finalAppraisal = (totalAppraisalValue[_nftAddress][tokenid])/(AllPricingSessions[_nftAddress][tokenid].totalVotes);
        listOfNfts.push(NftInformation(_nftAddress, tokenid));
        //End pricingSession
        AllPricingSessions[_nftAddress][tokenid].finalAppraisalSet = true;
        emit finalAppraisalDetermined(_nftAddress, tokenid, AllPricingSessions[_nftAddress][tokenid].finalAppraisal, AllPricingSessions[_nftAddress][tokenid].uniqueVoters);
    }
    
    /*
    At conclusion of pricing session we issue coins to users within ___ of price:
    
    Four factors:  size of pricing session (constant for all in session), 
                   size of total staking pool (constant for all in session),    
                   user stake (quadratic multiplier),  
                   accuracy (base)
    Equation = base * sqrt(personal stake) * sqrt(size of pricing session) * sqrt(total ETH in staking pool)
    Base Distribution:
        - 1% --> 5 $PP
        - 2% --> 4 $PP
        - 3% --> 3 $PP
        - 4% --> 2 $PP
        - 5% --> 1 $PP
        
    Should return true if the coins were issued correctly
    
    This logic is implemented in calculateBase and issueCoins functions

    Refer to calculateBaseLibrary on github for implementation
    */

    function calculateBase(address _nftAddress, uint tokenid) finalAppraisalComplete(_nftAddress, tokenid) public {
        //Set consequence for users that don't calculate their base before the window closes
        nftVotes[_nftAddress][tokenid][msg.sender].base = 0;
        require(AllPricingSessions[_nftAddress][tokenid].baseCalculated == false &&
            !(block.timestamp > AllPricingSessions[_nftAddress][tokenid].endTime + 2 days));
        /*
        Each of the following test the voters guess starting from 105 (5% above) and going down to 95 (5% below). 
        If true nftVotes[_nftAddress][tokenid][a].base is set to reflect the users base reward
        */
        
        //Calculates users base reward (Reference library implementation)
        nftVotes[_nftAddress][tokenid][msg.sender].base = 
            calculateBaseLibrary.calculateBase(
                AllPricingSessions[_nftAddress][tokenid].finalAppraisal, 
                nftVotes[_nftAddress][tokenid][msg.sender].appraisal
                );
    }
    
       /*
    Distribution formula --> 
    Four factors:  size of pricing session (constant for all in session), 
                   size of total staking pool (constant for all in session),    
                   user stake (quadratic multiplier),  
                   accuracy (base)
    Equation = base * sqrt(personal stake) * sqrt(size of pricing session) * fourth-rt(total ETH in staking pool)
    */
    function issueCoins(address _nftAddress, uint tokenid) public baseCalculatedComplete(_nftAddress, tokenid) returns(bool){
        require(AllPricingSessions[_nftAddress][tokenid].coinsIssued == false &&
            block.timestamp < AllPricingSessions[_nftAddress][tokenid].endTime + 4 days);
        uint amount; 
        //If pricing session size is under 20 users participants receive no reward, to stop users from making obscure pricing sessions
        if (addressesPerNft[_nftAddress][tokenid].length < 20) {
            amount = 0;
        }
        //If pricing session is 20 or larger then the pricing equation kicks in
        else if (addressesPerNft[_nftAddress][tokenid].length >= 20) {
            amount = IssueCoinComp.calcIssue(nftVotes[_nftAddress][tokenid][msg.sender].base, nftVotes[_nftAddress][tokenid][msg.sender].stake, addressesPerNft[_nftAddress][tokenid].length, AllPricingSessions[_nftAddress][tokenid].totalSessionStake);
        }
        //Mints the coins based on earned tokens and sends them to user at address a
        _mint(msg.sender, amount);
        totalCoinsIssued += amount;
        /*
        If user is not a coinHolder (i.e. isCoinHolder[a] is false) 
        this should push them to coinHolders list and set isCoinHolder to true.
        */
        if (isCoinHolder[msg.sender] = false) {
            //Added user to coinHolder list for coin distribution purposes
            coinHolders.push(msg.sender);
            //Recognize this holder has been added to the list
            isCoinHolder[msg.sender] = true;
        }
        //Adds to total tokens issued
        AllPricingSessions[_nftAddress][tokenid].tokensIssued += amount;
        AllPricingSessions[_nftAddress][tokenid].coinIssueEvents++;
        
        if (AllPricingSessions[_nftAddress][tokenid].coinIssueEvents == addressesPerNft[_nftAddress][tokenid].length){
            AllPricingSessions[_nftAddress][tokenid].coinsIssued = true;
        }
        else {
            AllPricingSessions[_nftAddress][tokenid].coinsIssued = false;
        }
        emit coinsIssued(amount, msg.sender);
        //returns true if function ran smoothly and correctly executed
        return true;
    }
    
    /*
    At conclusion of pricing session we harvest the losses of users
    that made guesses outside of the 5% over/under the finalAppraisalPrice
    
    Should return amount total loss harvest amount 
    */
    function harvestLoss(address _nftAddress, uint tokenid) coinsIssuedComplete(_nftAddress, tokenid) public {
        require(AllPricingSessions[_nftAddress][tokenid].lossHarvested == true &&
            block.timestamp < AllPricingSessions[_nftAddress][tokenid].endTime + 6 days);
       /*
       Checks users that are out of the money for how far over (in first if statement) 
       or under (in else if) they are and adjusts their stake balance accordingly
       */
        require(nftVotes[_nftAddress][tokenid][msg.sender].stake > 0);
        uint amountHarvested;
        amountHarvested = harvestLossLibrary.harvest( 
            nftVotes[_nftAddress][tokenid][msg.sender].stake, 
            nftVotes[_nftAddress][tokenid][msg.sender].appraisal,
            AllPricingSessions[_nftAddress][tokenid].finalAppraisal
            );
                
            AllPricingSessions[_nftAddress][tokenid].lossPoolTotal += amountHarvested;
            nftVotes[_nftAddress][tokenid][msg.sender].stake -= amountHarvested;
            if(lossPoolDistributionSession[nonce].active = true) {
                lossPoolDistributionSession[nonce + 1].poolSize += amountHarvested;
            }
            else {
                lossPoolDistributionSession[nonce].poolSize += amountHarvested;
            }
            profitGenerated += amountHarvested;
            
            //Send stake back and emit event confirming
            payable(msg.sender).transfer(nftVotes[_nftAddress][tokenid][msg.sender].stake);
            nftVotes[_nftAddress][tokenid][msg.sender].stake = 0;
            emit stakeRefunded(nftVotes[_nftAddress][tokenid][msg.sender].stake, msg.sender); 

        AllPricingSessions[_nftAddress][tokenid].lossHarvestEvents++;
        
        if (AllPricingSessions[_nftAddress][tokenid].lossHarvestEvents == addressesPerNft[_nftAddress][tokenid].length){
            AllPricingSessions[_nftAddress][tokenid].lossHarvested = true;
        }
        else {
            AllPricingSessions[_nftAddress][tokenid].lossHarvested = false;
        }
    } 
    
    function endSession(address _nftAddress, uint tokenid) checkSessionActive(_nftAddress, tokenid) public {
        require(block.timestamp > AllPricingSessions[_nftAddress][tokenid].endTime + 6 days);
        uint amount;
        if (addressesPerNft[_nftAddress][tokenid].length < 25) {
            amount = 0;
        }
        else {
            amount = 2 * sqrtLibrary.sqrt(sqrtLibrary.sqrt(addressesPerNft[_nftAddress][tokenid].length));
        }
        _mint(payable(msg.sender), amount);
        totalCoinsIssued += amount;
        AllPricingSessions[_nftAddress][tokenid].tokensIssued += amount;
        AllPricingSessions[_nftAddress][tokenid].active = false;
    }
    
    /*
    Loss pool should be divided by the amount of tokens in circulation and
    distributed to each coin holder wallet. For example if loss pool held 10 
    eth and there were 10 coins in circulation each coin would recieve 0.1 eth.
    
    Should return true if loss pool is completely distributed.
    
    balancOf(a) represents the user (address a) balance of $PP.
    _amount represents the calculate amount of ETH per token that is to be distributed.
    Function should return true if eth is successfully sent. 
    */
    function distributeLossPool() public returns(bool){
        //Make sure the msg.sender hasn't drawn from this session yet, its 30 days after last session, session still has ETH
        require(lossPoolAccessCheck[nonce][msg.sender] == false 
            && lPDSstartTime[nonce] >= lPDSstartTime[nonce - 1] + 32 days 
            && lossPoolDistributionSession[nonce].poolSize > 0);
        //Receiver is any owner of a $PP. Splits up contract balance and multiplies share per coin by user balancOf coins
        lossPoolAccessCheck[nonce][msg.sender] = true;
        //Send msg.sender their portion of the loss pool
        payable(msg.sender).transfer(balanceOf(msg.sender) * lossPoolDistributionSession[nonce].poolSize/lossPoolDistributionSession[nonce].PpToClaim);
        //Adjust lossPool balance to reflect ^^ transaction
        lossPoolDistributionSession[nonce].poolSize -= balanceOf(msg.sender) * lossPoolDistributionSession[nonce].poolSize/lossPoolDistributionSession[nonce].PpToClaim;
        lossPoolDistributionSession[nonce].PpToClaim -= balanceOf(msg.sender);
        emit lossPoolDistributed(balanceOf(msg.sender) * lossPoolDistributionSession[nonce].poolSize/lossPoolDistributionSession[nonce].PpToClaim, msg.sender);
        
        //Check if session has been completely drawn down, or the session has passed its time limit if either is true end the session
        if (lossPoolDistributionSession[nonce].poolSize == 0 || lPDSstartTime[nonce] + 2 days < block.timestamp){
            nonce++;
            lossPoolDistributionSession[nonce].poolSize += lossPoolDistributionSession[nonce - 1].poolSize;
            lossPoolDistributionSession[nonce - 1].poolSize = 0;
        }
        
        return true;
    }
    
    function getLossPoolRemainder() view public returns(uint) {
        return lossPoolDistributionSession[nonce].poolSize;
    }
    
    function getProfitsGenerated() view public returns(uint) {
        return profitGenerated;
    }
    
    function getTotalCoinsIssued() view public returns(uint) {
        return totalSupply();
    }
    
    function getTotalSessionStake(address _nftAddress, uint tokenid) view public returns(uint) {
        return AllPricingSessions[_nftAddress][tokenid].totalSessionStake;
    }
    
    function getEndTime(address _nftAddress, uint tokenid) view public returns(uint) {
        return AllPricingSessions[_nftAddress][tokenid].endTime;
    }
    
    function getTotalVoters(address _nftAddress, uint tokenid) view public returns(uint) {
        return addressesPerNft[_nftAddress][tokenid].length;
    }
    
    function getVote(address _nftAddress, uint tokenid) view public returns(uint) {
        return nftVotes[_nftAddress][tokenid][msg.sender].appraisal;
    }
    
    function getStake(address _nftAddress, uint tokenid) view public returns(uint) {
        return nftVotes[_nftAddress][tokenid][msg.sender].stake;
    }
    
    function getFinalAppraisal(address _nftAddress, uint tokenid) view public returns(uint) {
        return AllPricingSessions[_nftAddress][tokenid].finalAppraisal;
    } 

    function getTimeLeft() view public returns(uint) {
        return 32 days + lPDSstartTime[nonce-1] - block.timestamp; 
    }

    function getClaimActive() view public returns(bool) {
        return 32 days + lPDSstartTime[nonce-1] > block.timestamp;
    }

    function getLossPoolPortion() view public returns(uint) {
        return balanceOf(msg.sender) * lossPoolDistributionSession[nonce].poolSize/lossPoolDistributionSession[nonce].PpToClaim;
    }
}