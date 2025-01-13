/*🚀 20-Day Trigger Writing Challenge 🚀
    Trigger Scenario: 5/20
        
        "Prevent users from creating more than one Opportunity for the same Account. If a user tries to create an additional 
        Opportunity for an Account that already has one, the system should display an error message and block the operation."*/
        
        trigger PreventFromCreatingMoreThanOneOpp on Opportunity (before insert, before update) {
            // Collect Account IDs from the incoming Opportunity records
            set<Id> accIdSet = new set<Id>();
            for (Opportunity opp : trigger.new) {
                if(opp.AccountId!=null){
                    accIdSet.add(opp.AccountId);
                }
            }
            
            // Query Accounts and their related Opportunities created today
            list<Account> accRelOpp = [select id, Name, (select id, Name from Opportunity where createdDate = today) from Account where Id in :accIdSet];
            
            // Map to store the count of Opportunities for each Account
            map<Id, Integer> accIdToIntegerMap = new map<Id, Integer>();
            if(!accRelOpp.isEmpty()){
                for (Account acc : accRelOpp) {
                    accIdToIntegerMap.put(acc.Id, acc.Opportunities.size());
                }
            }
            
            // Validate if an Account already has an Opportunity created today
            for (Opportunity opps : trigger.new) {
                if (accIdToIntegerMap.get(opps.AccountId) >= 1) {
                    opps.addError('We cant create more than one opportunity');
                }
            }
        }