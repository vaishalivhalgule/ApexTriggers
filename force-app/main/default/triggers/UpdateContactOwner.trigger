/*🚀 20-Day Trigger Writing Challenge 🚀
Trigger Scenario: 15/20

"write a trigger if the owner of an account is changed the owner of the related contacts should also be update 
and also email id of the contact is null then validation error should be thrown."*/

trigger UpdateContactOwner on Account (before update) {
    list<Contact> contactsToUpdate=new list<Contact>();
    // Set to collect Account IDs where owner is changed
    set<Id> accountIdsWithOwnerChange=new set<Id>();
    
    // Check if Account owner is changed
    for(Account acc:trigger.new){
        if(trigger.oldMap.get(acc.Id).ownerId!=acc.ownerId){
            accountIdsWithOwnerChange.add(acc.Id);
        }
    }
    
    // Fetch related Contacts for the Accounts where owner changed
    list<Contact> relatedContacts=[select id,OwnerId,AccountId,email from contact where AccountId in:accountIdsWithOwnerChange];
    if(!relatedContacts.isEmpty()){
        for(contact con:relatedContacts){
            // Validate Email is not null 
            if(con.email==null){
                Account acc=trigger.newMap.get(con.AccountId);
                acc.addError('Related Contacts must have an Email before updating the Account owner.');
            }
            // Update Contact owner
            con.ownerId=trigger.newMap.get(con.AccountId).OwnerId;
            contactsToUpdate.add(con);
        }
    }
    
    // Update related Contacts' owner
    if(!contactsToUpdate.isEmpty()){
        update contactsToUpdate;
    }
}
