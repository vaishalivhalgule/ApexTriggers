/*🚀 20-Day Trigger Writing Challenge 🚀
Trigger Scenario: 13/20

"The organization wants to maintain data integrity by ensuring that no Account with associated Contacts can be deleted. 
When a user attempts to delete such an Account, they should see an error message: 
"Account cannot be deleted as it has related Contacts."*/

trigger PreventAccountDeletion on Account (before delete) {
    // Get all Account IDs being deleted
    set<Id> accIdSet=new set<Id>();
    for(Account acct:trigger.old){
        accIdSet.add(acct.Id);
    }
    
    // Query for related contacts of these accounts
    List<Account> accRelatedCons=[select Id,Name,(select Id,AccountId from Contacts) from Account where Id in:accIdSet];
    
    //Map Account ID to Contact Count
    map<id,Integer> AccIdToContactSizeMap=new map<id,Integer>();
    for(Account acc:accRelatedCons){
        if(acc.contacts.size()>0){
            AccIdToContactSizeMap.put(acc.Id,acc.Contacts.size());
        }
    }
    
    // Check if any account has related contacts
    for(Account acct:trigger.old){
        if(AccIdToContactSizeMap.containsKey(acct.Id) && AccIdToContactSizeMap.get(acct.Id)>0){
            acct.addError('Account cannot be deleted as it has related Contacts.');
        }
    }
}