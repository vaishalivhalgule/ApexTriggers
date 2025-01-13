/*🚀 20-Day Trigger Writing Challenge 🚀
Trigger Scenario: 14/20

"write a trigger to updates the Max_Opportunity_Amount__c field on the Account whenever an Opportunity is created, updated, or deleted, ensuring that the maximum amount is always the highest value from related Opportunities."*/

trigger TriggerMaxOpportunityAmountonAccount on Opportunity (after insert, after update, after delete, after undelete) {
    // Map to store the maximum Opportunity Amount for each Account
    Map<Id, Decimal> accountIdToMaxAmount = new Map<Id, Decimal>();
    
    // Collect Account IDs based on the trigger event
    Set<Id> accountIds = new Set<Id>();
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Opportunity opp : Trigger.new) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
            if(trigger.isafter && trigger.isupdate){
                Opportunity oldOpp=trigger.oldMap.get(opp.Id);
                accountIds.add(oldOpp.AccountId);
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
    
    // Query to calculate the max Opportunity Amount grouped by Account
    list<AggregateResult> agList=[SELECT AccountId, MAX(Amount) maxAmount FROM Opportunity WHERE AccountId IN :accountIds GROUP BY AccountId];
    
    if (!accountIds.isEmpty()) {
        for (AggregateResult result :agList) {
            Id accountId = (Id) result.get('AccountId');
            Decimal maxAmount = (Decimal) result.get('maxAmount');
            accountIdToMaxAmount.put(accountId, maxAmount);
        }
    }
    
    // Update the Max_Opportunity_Amount__c field on the Account
    List<Account> accountsToUpdate = new List<Account>();
    for (Id accountId : accountIds) {
        Account acc=new Account();
        acc.Id = accountId;
        acc.Max_Opportunity_Amount__c = accountIdToMaxAmount.get(accountId); 
        accountsToUpdate.add(acc);
    }
    
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}
