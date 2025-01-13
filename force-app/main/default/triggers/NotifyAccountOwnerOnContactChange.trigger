/*🚀 20-Day Trigger Writing Challenge 🚀
    Trigger Scenario: 7/20
        
        The organization wants to ensure that the Account owners are always informed when a new Contact is added or an 
        existing Contact is updated for their Accounts.*/
        
        trigger NotifyAccountOwnerOnContactChange on Contact (after insert,after update) {
            set<Id> accIdSet=new set<Id>();
            // Collect related Account IDs
            for(Contact con:trigger.new){
                if(con.AccountId!=null){
                    accIdSet.add(con.AccountId);
                }
            }
            // Query Account details
            Account acc=[select id,Owner.Email from Account where Id in:accIdSet limit 1];
            system.debug('Account Owner Email=='+acc.owner.Email);
            
            // Prepare email notifications
            list<Messaging.SingleEmailMessage> emails=new list<Messaging.SingleEmailMessage>();
            for(Contact con:trigger.new){
                Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
                email.setToAddresses(new string[] {acc.owner.email});
                email.setSubject('Contact'+(trigger.isinsert ? 'Inserted':'Updated'));
                email.setPlainTextBody('Contact has been'+ ' ' + (trigger.isinsert ? 'Inserted':'Updated')+ ' ' + 'Contact Name:' + con.FirstName +' ' +con.LastName);
                emails.add(email);
                
            }
            
            // Send emails
            if(!emails.isEmpty()){
                Messaging.sendEmail(emails);
            }
        }
