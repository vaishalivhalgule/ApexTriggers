/*🚀 20-Day Trigger Writing Challenge 🚀
    Trigger Scenario: 12/20
        
        "Create a trigger on the Account object that dynamically maintains the number of related Contact records based on the value of a custom field, No_Of_Cons__c.
        If the No_Of_Cons__c field increases, new contacts are created with default names based on the Account's name.
        If the No_Of_Cons__c field decreases, excess contacts are deleted to match the updated count."*/
        
        trigger ManageContactsBasedOnAccountField on Account (after insert,after update) {
            // List to store new contacts to be inserted
            list<Contact> insertConList=new list<Contact>();
            
            // Query to fetch all contacts related to the accounts in the trigger context
            // Used to calculate the current size of related contacts for each account
            list<Contact> accRelContactsList=[select id,AccountId from Contact where AccountId =:trigger.newMap.keySet()];
            integer contactCount=accRelContactsList.size();// Calculate the total number of related contacts
            
            if(trigger.isafter && (trigger.isinsert || trigger.isUpdate)){
                for(Account acc:trigger.new){
                    
                    // Check if the Number_of_Contacts__c field has changed and if more contacts need to be created
                    if(acc.Number_of_Contacts__c!=null && acc.Number_of_Contacts__c!=trigger.oldMap.get(acc.Id).Number_of_Contacts__c){
                        if(acc.Number_of_Contacts__c>contactCount){
                            
                            for(integer i=0;i<(acc.Number_of_Contacts__c-contactCount);i++){
                                contact con=new contact();
                                con.AccountId=acc.Id;
                                con.LastName=acc.Name + ' '+i;
                                insertConList.add(con);
                            }
                        }
                    }
                } 
            }
            if(!insertConList.isEmpty()){
                insert insertConList; 
            }
            
            // List to store contacts to be deleted
            list<Contact> deleteConList=new list<Contact>();
            
            if(trigger.isafter && trigger.isupdate){
                for(Account acc:trigger.new){
                    
                    // Check if the Number_of_Contacts__c field has changed and if excess contacts need to be deleted
                    if(acc.Number_of_Contacts__c!=null && acc.Number_of_Contacts__c!=trigger.oldMap.get(acc.Id).Number_of_Contacts__c){
                        if(contactCount>acc.Number_of_Contacts__c){
                            
                            for(integer i=0;i<(contactCount-acc.Number_of_Contacts__c);i++){
                                Contact con=new Contact();
                                con.AccountId=acc.Id;
                                con.Id=accRelContactsList[0].Id;// Use the first contact ID from the fetched list
                                deleteConList.add(con);
                            }
                        }
                    }
                }
            }
            if(!deleteConList.isEmpty()){
                delete deleteConList;
            }
        }