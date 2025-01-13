/*🚀 20-Day Trigger Writing Challenge 🚀
    Trigger Scenario: 11/20
        
"To ensure that the same phone number cannot be used for both an Account and a Contact. For example,
if a Contact record has the phone number 123-456-7890, users should not be able to create or update an Account with the same phone number. 
This trigger validates the Phone field on Accounts against existing Contacts and prevents the operation if a match is found"*/
        
trigger PreventSamePhoneforAccAndCon on Account (before insert,before update) {
    // Collect all unique phone numbers from incoming Account records
    Set<String> accPhoneSet = new Set<String>();
    for (Account acc : Trigger.new) {
        if (acc.Phone != null) {
            accPhoneSet.add(acc.Phone);
        }
    }
    
    // Query Contacts where their Phone matches the incoming Account Phone
    List<Contact> conList = [SELECT Id, Phone FROM Contact WHERE Phone IN :accPhoneSet AND AccountId in:trigger.new];
    
    // Use a Set to track Contact phone numbers
    Set<String> conPhoneSet = new Set<String>();
    for (Contact con : conList) {
        conPhoneSet.add(con.Phone);
    }
    // Check if any Account's phone matches with a Contact's phone
    for (Account acct : Trigger.new) {
        if (acct.Phone != null && conPhoneSet.contains(acct.Phone)) {
            acct.addError('An Account cannot have the same phone number as an existing Contact. Please use a unique phone number');
        }
    }
}