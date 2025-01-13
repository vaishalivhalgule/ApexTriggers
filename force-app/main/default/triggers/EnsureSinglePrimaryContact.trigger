/*🚀 20-Day Trigger Writing Challenge 🚀
    Trigger Scenario: 4/20
        "Write a trigger to ensure that only one 'Primary Contact' should be present on an account, and if 
        a user tried to add more than one 'Primary Contact' on an account whether by insertion or update then, in that case,
        you need to show an error message like:'An Account cannot have more than one Primary Contact.'
        Create a custom field on the Contact object named isPrimary__c (Checkbox)."*/
    
        trigger EnsureSinglePrimaryContact on Contact (before insert, before update) {
            // Collect all Account IDs from Trigger.new where isPrimary__c is true
            Set<Id> accountIds = new Set<Id>();
            for (Contact con : Trigger.new) {
                if (con.isPrimary__c == true && con.AccountId != null) {
                    accountIds.add(con.AccountId);
                }
            }
            
            if (!accountIds.isEmpty()) {
                // Query existing Primary Contacts for the affected Accounts
                Map<Id, Contact> accountToPrimaryContactMap = new Map<Id, Contact>();
                List<Contact> existingPrimaryContacts = [
                    SELECT Id, AccountId, isPrimary__c 
                    FROM Contact 
                    WHERE AccountId IN :accountIds AND isPrimary__c = true
                ];
                for (Contact con : existingPrimaryContacts) {
                    accountToPrimaryContactMap.put(con.AccountId, con);
                }
                
                // Validate Trigger.new records
                for (Contact con : Trigger.new) {
                    if (con.isPrimary__c == true && con.AccountId != null) {
                        Contact existingPrimary = accountToPrimaryContactMap.get(con.AccountId);
                        if (existingPrimary != null && existingPrimary.Id != con.Id) {
                            con.addError('An Account cannot have more than one Primary Contact.');
                        }
                    }
                }
            }
        }