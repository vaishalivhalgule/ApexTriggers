/*🚀 20-Day Trigger Writing Challenge 🚀
    Trigger Scenario: 9/20
        
        "Write a trigger to calculate and populate the total Opportunity Amount on the Account object by summing up the 
Amount field of all related Opportunities whenever an Opportunity is inserted, updated, deleted or undeleted, without using an aggregate query.."*/
        
trigger PopulateTotalOppAmountOnAccount on Opportunity (after insert,after update,after delete,after undelete) {
            
    //Collect all Account IDs from Opportunities
    Set<Id> accountIds = new Set<Id>();
    
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Opportunity opp : Trigger.new) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
    }
    
    if (Trigger.isDelete) {
        for (Opportunity opp : Trigger.old) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
    }
    
    //Query all Opportunities related to collected Account IDs
    Map<Id, Decimal> accountOpportunityAmountMap = new Map<Id, Decimal>();
    List<Opportunity> relatedOpportunities = [SELECT AccountId, Amount FROM Opportunity WHERE AccountId IN :accountIds];
    
    for (Opportunity opp : relatedOpportunities) {
        if (opp.AccountId != null) {
            if (!accountOpportunityAmountMap.containsKey(opp.AccountId)) {
                accountOpportunityAmountMap.put(opp.AccountId, 0); 
            }
            accountOpportunityAmountMap.put(opp.AccountId, accountOpportunityAmountMap.get(opp.AccountId) + opp.Amount);
        }
    }
    
    // Update Account records with the summed Opportunity Amounts
    List<Account> accountsToUpdate = new List<Account>();
    for (Id accId : accountOpportunityAmountMap.keySet()) {
        Account acc=new Account();
        acc.Id = accId;
        acc.Total_Opportunity_Amount__c = accountOpportunityAmountMap.get(accId);
        accountsToUpdate.add(acc);
    }
    
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate; 
    }
}