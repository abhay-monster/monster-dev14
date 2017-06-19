global class ArchiveContactBatch implements Database.Batchable<sObject>, Database.Stateful{

  global String updateErrors = '';
  global Integer batch_ct = 0;
  global Integer record_ct = 0;
  global Integer scopeSize = 0;
  global Integer cntct_ct = 0;

  global Database.QueryLocator start(Database.BatchableContext BC){

       String query = 'SELECT Id,firstName,LastName,Order_No__c,PrimaryBillingContact__c,CreatedDate,ContactStatus__c,Organization__c,Phone,Email FROM Contact WHERE ArchivalStatus__c != \'Archived\'';
        system.debug('Query >> '+ query);
        return Database.getQueryLocator(query);
        return null;
    }

     global void execute(Database.BatchableContext BC, List<Contact> scope){

           batch_ct++;
           record_ct += scope.size();
           if (scopeSize ==0){scopeSize = scope.size();}

           Id archiver = BatchUser__c.getInstance('Archiver').ID__c;
           List<Contact> contactLstTobeUpdated = new List<Contact>();
           Map<Id,ProductUserQuoteLine2OrderLine__c> productContactsMap = new Map<Id,ProductUserQuoteLine2OrderLine__c>();
           Map<Id,Task> taskContactMap = new Map<Id,Task>();
           Map<Id,account> billToContactMap = new Map<Id,Account>();
           Map<Id,case> caseContacts = new Map<Id,case>();
           set<String> firstNameSet = new set<string> {'-', '*', '.', '?', '??', 'Accounts', 'AT_UNKNOWN', 'Blank', 'DE_UNKNOWN', 'Dum', 'Firstname', 'General', 'Get First Name', 'Hiring', 'HR', 'Human', 'Manager', 'na', 'No', 'NO FIRST NAME', 'none', 'Not', 'Not Specified', 'NULL', 'Payable', 'Philly', 'Requires', 'resources', 'UNKNOWN', 'Valued', 'x', 'XXX'};
           set<String> lastNameSet = new set<string>{'-', '*', '.', '?', '??', 'Blank', 'NULL', 'LastName', 'Last Name', 'Not Specified', 'UNKNOWN'};
           //Set<String> organization1 = new set<string>{'North America', 'Europe', 'Default Organization', 'Temp', 'CSA'};
           //Set<String> organization2 = new set<string>{'Asia Pacific', 'North America', 'Europe', 'Default Organization', 'Temp', 'CSA'};


           for(ProductUserQuoteLine2OrderLine__c product : [SELECT Id,Contact_Name__c FROM ProductUserQuoteLine2OrderLine__c
                                                            WHERE Contact_Name__c != null]){
                     productContactsMap.put(product.Contact_Name__c,product);

                                                            }

           for(Task t : [select Id, WhatId from Task WHERE WhatId !=null]){

               taskContactMap.put(t.Id ,t);
           }

           for(Account acc: [SELECT Id,PrimaryBillingContact__c FROM Account WHERE PrimaryBillingContact__c!=null]){

               billToContactMap.put(acc.PrimaryBillingContact__c ,acc);
           }

           for(Case contactCase : [Select contactId from Case WHERE contactId != null] ){

               caseContacts.put(contactCase.contactId ,contactCase );

           }
               if(!scope.isEmpty()){
                   for(Contact con : scope){
                       if(con.Order_No__c == null && con.ContactStatus__c == 'Inactive'
                                                  && !productContactsMap.containsKey(con.Id)
                                                 // && organization1.contains(con.Organization__c)
                                                  ){

                                  con.ArchivalStatus__c= 'Archived';
                                  con.OwnerId = archiver;
                                  contactLstTobeUpdated .add(con);
                       }else if((con.CreatedDate < system.today().addYears(-1)) && !con.PrimaryBillingContact__c
                                 && !taskContactMap.containsKey(con.Id)
                                 && con.Phone == null
                                 && con.Email == null
                                 && !productContactsMap.containsKey(con.Id)
                                 && !billToContactMap.containsKey(con.Id)
                                 && !caseContacts.containsKey(con.Id)
                                 //&& organization1.contains(con.Organization__c)
                                 ){

                                 con.ArchivalStatus__c= 'Archived';
                                 con.OwnerId = archiver;
                                 contactLstTobeUpdated .add(con);
                         } else if((firstNameSet.contains(con.firstName) || lastNameSet.contains(con.LastName))
                                    && con.Phone == null
                                    && con.Email == null
                                    && con.Order_No__c == null
                                    //&& organization2.contains(con.Organization__c)
                                    ){

                                    con.ArchivalStatus__c= 'Archived';
                                    con.OwnerId = archiver;
                                    contactLstTobeUpdated .add(con);
                         }
                    }
                }

                if(contactLstTobeUpdated.size() > 0){
                  cntct_ct += contactLstTobeUpdated.size();
                  updateErrors += ArchiveHelper.doUpdate('Contact', contactLstTobeUpdated);
                }
       }

      global void finish(Database.BatchableContext BC){
        String objectName = 'Contact';
        String summary = '';
        summary += record_ct + ' ' + objectName + ' records were processed ';
        summary += 'in ' + batch_ct + ' batches of up to ' + scopeSize + ' records each.<BR><BR>';
        summary += 'The following counts of records were flagged for archiving:<BR>';
        summary += cntct_ct + ' ' + objectName + ' record(s)<BR>';
        ArchiveHelper.sendEmail(objectName, summary, updateErrors);
    }
}