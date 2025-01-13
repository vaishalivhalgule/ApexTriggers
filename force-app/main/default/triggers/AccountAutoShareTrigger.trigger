/*🚀 20-Day Trigger Writing Challenge 🚀
 Trigger Scenario: 16/20

"When a new Account is created in Salesforce, the system automatically shares the Account record with the first active user who has the 'Standard User' profile, granting them 'Read' access to the Account and its related Opportunities."

Apex Sharing-Apex Sharing is a programmatic way to share records in Salesforce when the standard sharing rules and settings are not sufficient to meet specific business requirements.

For example, AccountShare is the sharing object for the Account object, ContactShare is the sharing object for the Contact object & for the custom object,
MyCustomObject is the name of the custom object:
MyCustomObject__Share

Note:Objects on the detail side of a master-detail relationship don’t have an associated sharing object.*/ 

trigger AccountAutoShareTrigger on Account (after insert) {
    if(trigger.isafter && trigger.isafter){
         // Getting ProfileId based on ProfileName
        Id standardUserProfileId=[select id from Profile where Name='Standard User' limit 1].Id;
        
        // Getting the UserId using the standardUserProfileId and ensuring the user is active
        list<User> userIdList=[select Id from user where ProfileId=:standardUserProfileId AND IsActive = TRUE limit 1];
        
        // Creating a list to store AccountShare records to be inserted
        list<AccountShare> accountShareList=new list<AccountShare>();
        
        // Loop through the new accounts and create corresponding AccountShare records
        for(Account acc:trigger.new){
            AccountShare accShareObj=new AccountShare();
            accShareObj.AccountId=acc.Id;
            accShareObj.UserOrGroupId = userIdList.isEmpty() ? null : userIdList[0].Id;
            accShareObj.AccountAccessLevel='Read';
            accShareObj.OpportunityAccessLevel='Read';
            accShareObj.RowCause = 'Manual';
            accountShareList.add(accShareObj);
        }
        // Insert the AccountShare records if the list is not empty
        if (!accountShareList.isEmpty()) {
            insert accountShareList;
        }
    }
    
}