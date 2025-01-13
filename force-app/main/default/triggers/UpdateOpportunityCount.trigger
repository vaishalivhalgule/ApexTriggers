/*🚀 20-Day Trigger Writing Challenge 🚀
    Trigger Scenario: 3/20
        
        write a trigger that updates the count of Opportunities on the related Account every time an Opportunity is inserted,
        updated, deleted or undeleted.*/
        
        trigger UpdateOpportunityCount on Opportunity (after insert,after update,after Delete,after undelete) {
            
            // Create a set to hold the Account IDs that need to be updated
            set<Id> accIdSet=new set<Id>();
            list<Account> accountsToUpdate=new list<Account>();
            
            // Collect the Account IDs from the Opportunity records that triggered the event
            if(trigger.isafter && trigger.isinsert || trigger.isundelete){
                for(Opportunity opp:trigger.new){
                    if(opp.Account!=null){
                        accIdSet.add(opp.AccountId);
                    }
                }
            }
            
            if(trigger.isafter && trigger.isupdate){
                for(Opportunity opp:trigger.new){
                    if(opp.AccountId!=null){
                        accIdSet.add(opp.AccountId);
                        Opportunity oldOpp=trigger.oldMap.get(opp.Id);
                        accIdSet.add(oldOpp.AccountId);
                    }
                    
                }
            }
            
            if(trigger.isafter && trigger.isdelete){
                for(Opportunity opp:trigger.old){
                    if(opp.Account!=null){
                        accIdSet.add(opp.AccountId);
                    }
                }
            }
            
            system.debug('accIdSet'+accIdSet);
            
            // Query the Account records and update the Opportunity count
            list<Account> accList=[select Id,Name,Number_of_Opportunities__c,(select Id,Name from Opportunities) from Account where Id in:accIdSet];
            system.debug('accList'+accList);
            // Update the Opportunity count for each Account
            if(!accList.isEmpty()){
                for(Account acc:accList){
                    acc.Number_of_Opportunities__c=acc.Opportunities.size();
                    accountsToUpdate.add(acc);
                } 
            }
            // Update the Account records with the new Opportunity count
            if(!accList1.isEmpty()){
                update accountsToUpdate;
            }
        }
