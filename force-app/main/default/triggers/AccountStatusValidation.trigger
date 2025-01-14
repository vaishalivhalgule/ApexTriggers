/*🚀 20-Day Trigger Writing Challenge 🚀
 Trigger Scenario: 17/20

"If the user attempts to change the Status__c field on the Account from 'Active' to 'Not Active,' 
the system should validate whether there are any Open Opportunities (Opportunities that are not Closed Won 
or Closed Lost) associated with the Account. If such Opportunities exist, the system should prevent the change
 and display an appropriate error message to the user."*/

trigger AccountStatusValidation on Account (before update) {
    // Set to collect Account IDs where Status is changing from "Active" to "Not Active"
    set<Id> accIds=new set<id>();
    // Identify Accounts where Status is being changed from "Active" to "Not Active"
    for(Account acc:trigger.new){
        if(acc.Status__c=='Not Active' && trigger.oldMap.get(acc.Id).Status__c=='IsActive'){
            accIds.add(acc.Id);
        }
    }
    // Query related Open Opportunities for the identified Accounts
    List<Opportunity> relatedOpps=[select Id,AccountId,StageName from Opportunity where AccountId in:accIds AND StageName!='Closed Won' AND StageName!='Closed Lost'];
    
    // Map to track Accounts with Open Opportunities
    set<Id> accIdsWithOpenOpps=new set<Id>();
    
     // Populate the set with Account IDs that have Open Opportunities
    for(Opportunity opp:relatedOpps){
        if(opp.AccountId!=null){
            accIdsWithOpenOpps.add(opp.AccountId);
        } 
    }
    // Prevent changing the Status if there are Open Opportunities associated with the Account
    for(Account acc:trigger.new){
        if(accIdsWithOpenOpps.contains(acc.Id)){
            acc.Status__c.addError('Cannot change Status to "Not Active" because there is an Open Opportunity associated with this Account.');
        }
    }
}