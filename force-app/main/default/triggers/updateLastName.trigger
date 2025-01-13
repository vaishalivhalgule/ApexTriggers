/*🚀 20-Day Trigger Writing Challenge 🚀
    Trigger Scenario: 6/20
        
        When the LastName of any Contact is updated, all other Contacts associated with the same Account should automatically 
        reflect the updated LastName to maintain uniformity across all Contacts linked to that Account.*/
        
        trigger updateLastName on Contact(after update){
            list<Contact> updateConList=new list<Contact>();
            map<Id,String> idToStringMap=new map<Id,String>();
            
            // Collect AccountId and LastName where the LastName is updated
            for(Contact con:trigger.new){
                if(con.LastName!=trigger.oldMap.get(con.Id).LastName && con.AccountId!=null){
                    idToStringMap.add(con.AccountId,Con.LastName);
                }
            }
            
            // Query all Contacts related to these Accounts
            list<Contacts> ConList=[select Id,LastName from Contact where AccountId in:idToStringMap.keyset()];
            
            // Update LastName for all related Contacts
            if(!ConList.isEmpty()){
                for(contact cont:ConList){
                    cont.LastName=idToStringMap.get(cont.AccountId);
                    updateConList.add(cont);
                }
            }
            if(!updateConList.isEmpty()){
                update updateConList;
            }
        }/*🚀 20-Day Trigger Writing Challenge 🚀
    Trigger Scenario: 6/20
        
        When the LastName of any Contact is updated, all other Contacts associated with the same Account should automatically 
        reflect the updated LastName to maintain uniformity across all Contacts linked to that Account.*/
        
        trigger updateLastName on Contact(after update){
            list<Contact> updateConList=new list<Contact>();
            map<Id,String> idToStringMap=new map<Id,String>();
            
            // Collect AccountId and LastName where the LastName is updated
            for(Contact con:trigger.new){
                if(con.LastName!=trigger.oldMap.get(con.Id).LastName && con.AccountId!=null){
                    idToStringMap.add(con.AccountId,Con.LastName);
                }
            }
            
            // Query all Contacts related to these Accounts
            list<Contacts> ConList=[select Id,LastName from Contact where AccountId in:idToStringMap.keyset()];
            
            // Update LastName for all related Contacts
            if(!ConList.isEmpty()){
                for(contact cont:ConList){
                    cont.LastName=idToStringMap.get(cont.AccountId);
                    updateConList.add(cont);
                }
            }
            if(!updateConList.isEmpty()){
                update updateConList;
            }
        }