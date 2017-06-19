@isTest
private  class LeadTriggerTest {
    
    // Lead Creation test
    static testMethod void testCreationLeadTrigger(){
        Lead ld;
        Account acc;
        User usr;
        Opportunity opp;
        
        // Lead Creation Process
        ld = TestDataSetupUtility.createTestLead();
        ld.Posting_Street__c = 'test123';
        ld.Street = '';
        Test.startTest();      
        insert ld;
        // Verify that  Posting_Street__c copied into Street field
        ld = [Select Id, Posting_Street__c ,Street from Lead Where Id = :ld.Id];   
        System.assertEquals(ld.Street, 'test123');
        Test.stopTest();
    }
    
    // Lead Conversion test
    static testMethod void testLeadConversion(){
        
        Lead lead;  
        User usr;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
        insert usr;
        
        // Lead Creation Process
        lead= TestDataSetupUtility.createTestLead();
        lead.Registration__c = '123';
        
        Test.startTest(); 
        system.runAs(usr){
            system.debug(LoggingLevel.INFO,'LEADTRIGGERTEST - INSERT LEAD');
            insert lead;
            system.debug(LoggingLevel.INFO, 'LEADTRIGGERTEST - Dump Lead after Insert: ' + lead);
            Database.LeadConvert lc1 = new database.LeadConvert();
            lc1.setLeadId(lead.Id);
           // lc1.setDoNotCreateOpportunity(true);
            LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true and MasterLabel != 'Qualified' limit 1];
            lc1.setConvertedStatus(convertStatus.MasterLabel);
            system.debug(LoggingLevel.INFO,'LEADTRIGGERTEST - CONVERTING LEAD');
            Database.LeadConvertResult lcr1 = Database.convertLead(lc1);
            system.debug(LoggingLevel.INFO, 'LEADTRIGGERTEST - Dump Lead after ConvertLead: ' + lead);
            
            // Verify lead is converted  
            System.assertEquals(true,lcr1.isSuccess());
            lead = [Select IsConverted from Lead where Id =: lead.Id];     
            System.assertEquals(lead.IsConverted, true);
            system.debug(LoggingLevel.INFO,'LEADTRIGGERTEST - PAST THE CONVERSION ASSERTION');
            //system.debug(LoggingLevel.INFO, 'LEADTRIGGERTEST - MAKING EDITS TO TEST ANOTHER CALL TO AFTER UPDATE');
            
            //List<Lead> convertedLeads = [Select Id, convertedAccountId, convertedOpportunityId, ConvertedContactId, IsConverted from Lead Where Id =:lead.Id ];
            //system.assert(false,'@*@*@* IsConverted: '+convertedLeads[0].IsConverted + ' AccountId: ' + convertedLeads[0].convertedAccountId + ' OptyId: ' + convertedLeads[0].convertedOpportunityId + ' ConId: ' + convertedLeads[0].ConvertedContactId);
            //system.debug(LoggingLevel.INFO,'LEADTRIGGERTEST - EXPLICIT CALL TO ONAFTERUPDATE');
            //leadTriggerHandler.onAfterUpdate(convertedLeads, null); 
        }
        Test.stopTest();
        
    }
    
}