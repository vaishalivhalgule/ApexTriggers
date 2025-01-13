/*🚀 20-Day Trigger Writing Challenge 🚀
Trigger Scenario: 10/20

''Whenever a new contact is created, their full name should be appended to the existing description of the related account. 
This helps account managers quickly view all associated contacts without navigating to the Contacts tab."*/

trigger UpdateConNameOnAccoutDescription on Contact (after insert) {
    // Create a map to store account ID and the list of contact names
    Map<Id,list<String>> accIdToConName=new Map<Id,list<String>>();
    
    // Iterate through the newly inserted contacts
    for(Contact con:trigger.new){
        if(con.AccountId!=null){
            // Initialize the list if not already present in the map
            if (!accIdToConName.containsKey(con.AccountId)) {
                accIdToConName.put(con.AccountId,new list<String>());
            }
            // Add the contact's name to the list
            String fullName = con.FirstName + ' ' + con.LastName;
            accIdToConName.get(con.AccountId).add(fullName);
        }
    }
    
    // Fetch existing accounts to update their descriptions
    list<Account> conRelatedAccount=[select id,Name,description from Account where Id in:accIdToConName.keySet()];
    
    list<Account> updateaccList=new list<Account>();
    for(Account acc:conRelatedAccount){
        if(accIdToConName.containsKey(acc.Id)){
            // Append the new contact names to the description
            String existingDescription = acc.Description == null ? '' : acc.Description + '\n';
            acc.Description=existingDescription + ' ' + String.join(accIdToConName.get(acc.Id), ', ');
            updateaccList.add(acc);
        }
    }
    // Update accounts with the new description
    if(!updateaccList.isEmpty()){
        update updateaccList;
    }
}