/*🚀 20-Day Trigger Writing Challenge 🚀
    Trigger Scenario: 2/20
        Write a trigger upon the deletion of an Opportunity, a Task is automatically created for the parent Account's Owner.
        
        WhoId:
        It is used to associate the Task or Event with a Lead or Contact.
        Examples:
        If a Task is related to a specific Contact, the WhoId field stores the Contact's ID.
        If it's related to a Lead, the WhoId field stores the Lead's ID.
    
        WhatId:
        It is used to associate the Task or Event with an Account, Opportunity, Case, Campaign, or any custom object.
        Examples:
        If a Task is related to an Account, the WhatId field stores the Account's ID.
        If it's related to an Opportunity, the WhatId field stores the Opportunity's ID.*/
        
        
        trigger CreateTaskOnOpportunityDelete on Opportunity (after delete) {
            set<Id> accIdSet=new set<Id>();
            list<Task> createTask=new list<Task>();
            for(Opportunity opp:trigger.old){
                if(opp.AccountId!=null){
                    accIdSet.add(opp.AccountId);
                }
            }
            
            list<Account> accList=[select Id,ownerId from Account where Id in:accIdSet];
            map<Id,Account> idToAccountMap=new map<Id,Account>();
            for(Account acc:accList){
                idToAccountMap.put(acc.Id,acc);
            }
            
            for(Opportunity opp:trigger.old){
                if(idToAccountMap.containsKey(opp.AccountId) && opp.AccountId!=null){
                    Account acc=idToAccountMap.get(opp.AccountId);
                    
                    Task task=new Task();
                    task.subject='follow up on deleted Opportunity';
                    task.Description='The Opportunity'+opp.Name+ 'was deleted';
                    task.OwnerId=acc.OwnerId;
                    task.WhatId=opp.AccountId;
                    task.Priority='High';
                    task.Status='Not Started';
                    createTask.add(task);
                }
            }
            if(!createTask.isEmpty()){
                insert createTask;
            }
        }