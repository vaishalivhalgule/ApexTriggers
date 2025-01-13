/*🚀 20-Day Trigger Writing Challenge 🚀
    Trigger Scenario: 8/20
        
        "Write a trigger to ensure that users can create only one opportunity per account per day, 
        preventing multiple opportunities from being created for the same account within the same calendar day."*/
        
        trigger preventMoreThanOneOppPerDay on Opportunity (before insert,before update) {
            set<id> accIdSet=new set<id>();
            //Collect all Account IDs from the incoming opportunities
            for(Opportunity opp:trigger.new){
                if(opp.AccountId!=null){
                    accIdSet.add(opp.AccountId);
                }
            }
            
            map<Id,Integer> oppIdToIntegerMAp=new map<Id,Integer>();
            //Query related accounts and their opportunities created today
            list<Account> existingAccRelOpp=[select Id,Name,(select id,Name from Opportunities where createdDate=today) from Account where Id in:accIdSet ];
            //Map Account IDs to the count of today's opportunities
            if(!existingAccRelOpp.isEmpty()){
                for(Account acc:existingAccRelOpp){
                    oppIdToIntegerMAp.put(acc.Id,acc.Opportunities.size());
                }
            }
            
            //Validate opportunities being processed
            for(opportunity opp:trigger.new){
                if(oppIdToIntegerMAp!=null && oppIdToIntegerMAp.get(opp.AccountId)>=1){
                    opps.addError('todays limit exceded ,we cant create more than one');
                }
            } 
        }
