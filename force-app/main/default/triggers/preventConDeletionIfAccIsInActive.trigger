/*🚀 20-Day Trigger Writing Challenge 🚀
    
    Trigger Scenario: 1/20
        Prevents the deletion of a Contact record if the associated Account is active.(Without Nesting for loop)*/
        
        trigger preventConDeletionIfAccIsInActive on Contact (before delete) {
            
            // Collect all Account IDs associated with the Contacts being deleted
            set<id> accIdSet=new set<id>();
            for(Contact con:trigger.old){
                if(con.AccountId!=null){
                    accIdSet.add(con.AccountId);
                }
                system.debug('accIdSet==' +accIdSet);
            }
            
            list<Account> accList=[select id,Is_Active__c from Account where Id in:accIdSet];
            system.debug('accList==' +accList);
            // Query the Accounts and store their active status in a Map
            map<Id,Boolean> IdToBooleanMap=new map<Id,Boolean>();
            
            for(Account acc:accList){
                IdToBooleanMap.put(acc.Id,acc.Is_Active__c);
            }
            system.debug('IdToBooleanMap==' +accIdSet);
            
            // Prevent deletion if the associated Account is active
            for(Contact con:trigger.old){
                if(con.AccountId!=null && IdToBooleanMap.get(con.AccountId)==true){
                    con.addError('You cannot delete this Contact because the associated Account is active.');
                }
            }
        }