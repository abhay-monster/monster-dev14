/*************************************************************************************************************
* Class : EmailMessageTriggerHandlerTest
* @author Mohit Parnami
* @CreatedDate  : 1 Sept 2015
* @Description : Test Class of EmailMessageTriggerHandler 
***************************************************************************************************************/
@isTest 
public with sharing class EmailMessageTriggerHandlerTest {

        @testSetup
        static void preTestSetup(){
                TestDataSetupUtility.createCatchAllRule();

                Profile pAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                Profile pNonAdmin = [SELECT Id FROM Profile WHERE Name = 'Sales Rep (NA)' LIMIT 1];
            
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', pAdmin.Id);
                //insert usr;
                User ussr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad1', pAdmin.Id);
                User usrNonAdmin =  TestDataSetupUtility.createTestUser('Test ', ' SalesRep', pNonAdmin.Id);
                insert new List<User>{ussr,usr,usrNonAdmin};
                Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = false;
                personalSettings.trigger_account__c = false;
                insert personalSettings;
            
            	
        }

    static testmethod void testEmailMessageCreate(){

                /*Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                insert usr;*/
                List<User> usrList = [Select Id from User  Limit 3];
                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usrList[0].Id);
                cse.Status= 'Closed';
                cse.ClosedDate = date.today().addDays(-50);
                cse.CreatedDate = date.today().addDays(-50); 
                Test.startTest();
                insert cse;
                
                EmailMessage em = TestDataSetupUtility.createEmailMessage(cse.Id, true, true);
        
                Case csse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usrList[1].Id);
                csse.Status= 'Closed';
                csse.ClosedDate = date.today().addDays(-60);
                csse.CreatedDate = date.today().addDays(-60); 
                //insert csse;
                
                EmailMessage em1 = TestDataSetupUtility.createEmailMessage(cse.Id, true, true);

                List<EmailMessage> listem = [Select id From EmailMessage];
                //System.assertEquals(listem.size(),2);
                delete em;
                Test.stopTest();
        }

        static testmethod void testEmail2CaseRouting(){
            Test.startTest();
                /*Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings; */

                /*Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                insert usr;*/
                User usr = [Select Id from User Where Name='Test Sys Ad' Limit 1];
                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id); 
                //cse.SuppliedName = 'Joe Bloggs';
                //cse.SuppliedEmail = 'test@test.com';
                insert cse;

                Id emailRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('CaseRoutingRule__c', 'Email');         

                CaseRoutingRule__c caseRouting  = TestDataSetupUtility.createCaseRoutingRecord();
                QueueSobject q = [select CreatedById, Id, QueueId, SobjectType, SystemModstamp from QueueSobject Where Sobjecttype = 'Case' Limit 1];
                caseRouting.OWnerId = q.QueueId;
                caseRouting.RecordTypeId = emailRecordTypeId;
                caseRouting.SFDC_Routing_Address__c = 'gcsnatestsf';
                insert CaseRouting;      

                EmailMessage em = TestDataSetupUtility.createEmailMessage(cse.Id, true, true);

                List<Case> listCase = [Select id, OwnerId, Priority From Case Where Id = :cse.Id];
                System.assertEquals(listCase[0].OwnerId,q.QueueId);     
            Test.stopTest();
        }

        static testmethod void testEmail2CaseMultipleRouting(){
            Test.startTest();
                /*Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings; */

                /*Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                insert usr;*/
                User usr = [Select Id from User Where Name='Test Sys Ad' Limit 1];
                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id); 
                //cse.SuppliedName = 'Joe Bloggs';
                //cse.SuppliedEmail = 'test@test.com';
                insert cse;         

                Id emailRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('CaseRoutingRule__c', 'Email');
                CaseRoutingRule__c caseRouting  = TestDataSetupUtility.createCaseRoutingRecord();
                QueueSobject q = [select CreatedById, Id, QueueId, SobjectType, SystemModstamp from QueueSobject Where Sobjecttype = 'Case' Limit 1];
                caseRouting.OWnerId = q.QueueId;
                caseRouting.SenderEmailContains__c = 'test@test.com';
                caseRouting.EmailBodyContains__c = '';
                caseRouting.EmailSubjectContains__c = '';
                caseRouting.RecordTypeId = emailRecordTypeId;
                caseRouting.SFDC_Routing_Address__c = 'gcsnatestsf';
                insert CaseRouting; 
                CaseRoutingRule__c caseRouting2  = TestDataSetupUtility.createCaseRoutingRecord();
                caseRouting2.SFDC_Routing_Address__c = 'gcsnatestsf';
                caseRouting2.OWnerId = q.QueueId;
                insert CaseRouting2;     

                EmailMessage em = TestDataSetupUtility.createEmailMessage(cse.Id, true, true);

                List<Case> listCase = [Select id, OwnerId, Priority From Case Where Id = :cse.Id];
                System.assertEquals(listCase[0].OwnerId,q.QueueId);
            Test.stopTest();
        }

        static testmethod void testEmail2CaseMismatchRouting(){
            Test.startTest();
                /*Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings; */

                /*Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                insert usr;*/
                User usr = [Select Id from User Where Name='Test Sys Ad' Limit 1];
                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id); 
                //cse.SuppliedName = 'Joe Bloggs';
                //cse.SuppliedEmail = 'test@test.com';
                insert cse;         

                CaseRoutingRule__c caseRouting  = TestDataSetupUtility.createCaseRoutingRecord();
                QueueSobject q = [select CreatedById, Id, QueueId, SobjectType, SystemModstamp from QueueSobject Where Sobjecttype = 'Case' Limit 1];
                caseRouting.OWnerId = q.QueueId;
                insert CaseRouting; 
                CaseRoutingRule__c caseRouting2  = TestDataSetupUtility.createCaseRoutingRecord();
                caseRouting2.Emailheadercontains__c = 'TestBlahBlah';
                insert CaseRouting2;     
                CaseRoutingRule__c caseRouting3  = TestDataSetupUtility.createCaseRoutingRecord();
                caseRouting3.Emailheadercontains__c = 'Testing123';
                caseRouting3.SenderEmailContains__c = 'test@test.com';
                insert CaseRouting3;  
                CaseRoutingRule__c caseRouting4 = TestDataSetupUtility.createCaseRoutingRecord();
                caseRouting4.SenderEmailContains__c = 'test@test.com';
                caseRouting4.Emailheadercontains__c = 'garbage';
                insert CaseRouting4;  

                EmailMessage em = TestDataSetupUtility.createEmailMessage(cse.Id, true, true);

                List<Case> listCase = [Select id, OwnerId, Priority From Case Where Id = :cse.Id];
                //System.assertEquals(listCase[0].OwnerId,q.QueueId);       
            Test.stopTest();         
        }
    
    // TK I-228933: adding additional test method to increase test coverage
    // Test Using [AND] and [OR] logic in subject or other routing rule criteria fields
    static testmethod void testEmail2CaseRoutingWithLogic(){ 
                
                
                Test.startTest();
        		EmailTemplate et = [Select id, developername, IsActive From EmailTemplate Where IsActive = true Limit 1];
            	
                User usr = [Select Id from User Where Name='Test SalesRep' Limit 1];
                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id); 
                //cse.SuppliedName = 'Joe Bloggs';
                //cse.SuppliedEmail = 'test@test.com';
                insert cse;

                Id emailRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('CaseRoutingRule__c', 'Email');         

                CaseRoutingRule__c caseRouting1  = TestDataSetupUtility.createCaseRoutingRecord();
                CaseRoutingRule__c caseRouting2  = TestDataSetupUtility.createCaseRoutingRecord();
                CaseRoutingRule__c caseRouting3  = TestDataSetupUtility.createCaseRoutingRecord();
        
                QueueSobject q = [select CreatedById, Id, QueueId, SobjectType, SystemModstamp from QueueSobject Where Sobjecttype = 'Case' Limit 1];
                caseRouting1.OwnerId = q.QueueId;
                caseRouting1.RecordTypeId = emailRecordTypeId;
                caseRouting1.EmailSubjectContains__c = 'Test [OR] Email [AND] 1234 [NOT] 5 [AND NOT] 6 [OR NOT] 7';
                caseRouting1.EmailBodyContains__c = 'Body';
                caseRouting1.SenderEmailContains__c = 'Test [AND] com';
                caseRouting1.InboundEmailAddress__c = '';
                caseRouting1.SFDC_Routing_Address__c = 'fraudtestsf';
        		caseRouting1.AutoResponseTemplate__c = et.DeveloperName;
        		caseRouting1.FromAddressforAutoResponse__c = 'customerservice@monster.com';
                insert CaseRouting1;
        
                caseRouting2.OwnerId = q.QueueId;
                caseRouting2.RecordTypeId = emailRecordTypeId;
                caseRouting2.EmailSubjectContains__c = 'Test [OR] Subject [AND] 1234 [NOT] 5 [AND NOT] 6 [OR NOT] 7';
                caseRouting2.EmailBodyContains__c = 'Body';     
                caseRouting2.SenderEmailContains__c = 'Test@test.com';
                caseRouting2.InboundEmailAddress__c = 'GCSNATestSF_TEST1@monster.com';
                caseRouting2.SFDC_Routing_Address__c = 'gcsnatestsf';
        		caseRouting2.AutoResponseTemplate__c = et.DeveloperName;
        		caseRouting2.FromAddressforAutoResponse__c = 'customerservice@monster.com';
                insert CaseRouting2;
        
                caseRouting3.OwnerId = q.QueueId;
                caseRouting3.RecordTypeId = emailRecordTypeId;
                caseRouting3.EmailSubjectContains__c = 'Test [OR] Subject [AND] 1234 [NOT] 5 [AND NOT] 6 [OR NOT] 7';
                caseRouting3.EmailBodyContains__c = 'Body';
                caseRouting3.SenderEmailContains__c = 'Test@test.com';
                caseRouting3.InboundEmailAddress__c = 'GCSNATestSF_TEST2@monster.com';
                caseRouting3.SFDC_Routing_Address__c = 'gcsnatestsf';
        		caseRouting3.AutoResponseTemplate__c = et.DeveloperName;
        		caseRouting3.FromAddressforAutoResponse__c = 'customerservice@monster.com';
                insert CaseRouting3;

                EmailMessage em = TestDataSetupUtility.createEmailMessage(cse.Id, true, false);
                em.fromaddress = 'Test@test.com';
                em.toaddress = 'GCSNATestSF_TEST1@monster.com; GCSNATestSF_TEST2@monster.com';
                em.BccAddress = 'FraudTestSF_TEST@monster.com';
                em.subject = 'Test Subject 1234';
                em.textbody = 'Test Body 1234';
                
                insert em;

                List<Case> listCase = [Select id, OwnerId, Priority From Case Where Id = :cse.Id];
                System.assertEquals(listCase[0].OwnerId,q.QueueId); 
        
                // Test Deletion of Email Message - to get test coverage on line 20 of EmailMessageTrigger
                // 
                System.runAs(usr) {
                    try {
                        if(Test.isRunningTest()){ delete cse;}
                    } 
                    catch(DmlException e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                        System.assert(e.getMessage().contains('Delete failed'), 'message=' + e.getMessage());
                    }
                                      
                }
                Test.stopTest();
        }
    
    static testmethod void testEmail2CaseCatchAllRouting(){ 
			//  This method still needs some work - didn't improve the code coverage - trying to cover EmailMessageTriggerHandler method checkInnerCatchAllRoutingMatch
                Test.startTest();
        		EmailTemplate et = [Select id, developername, IsActive From EmailTemplate Where IsActive = true Limit 1];            	
                User usr = [Select Id from User Where Name='Test SalesRep' Limit 1];
                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id); 
                //cse.SuppliedName = 'Joe Bloggs';
                //cse.SuppliedEmail = 'test@test.com';
                insert cse;
        		

                Id emailRecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('CaseRoutingRule__c', 'Email');         

                CaseRoutingRule__c caseRouting1  = TestDataSetupUtility.createCaseRoutingRecord();
                CaseRoutingRule__c caseRouting2  = TestDataSetupUtility.createCaseRoutingRecord();
                CaseRoutingRule__c caseRouting3  = TestDataSetupUtility.createCaseRoutingRecord();
        		
        		// Inner Catch All
                Group Owner1 = [select Id from Group where DeveloperName = 'GCS_Admin' Limit 1]; //DACH_SKR
        		Group Owner2 = [select Id from Group where DeveloperName = 'DACH_SKR' Limit 1]; //
        		//QueueSobject q1 = [select CreatedById, Id, QueueId, SobjectType, SystemModstamp from QueueSobject Where Sobjecttype = 'Case' Limit 1];
        		//QueueSobject q2 = [select CreatedById, Id, QueueId, SobjectType, SystemModstamp from QueueSobject Where Sobjecttype = 'Case' Limit 1];
                caseRouting1.OwnerId = Owner1.Id;
                caseRouting1.RecordTypeId = emailRecordTypeId;
                caseRouting1.EmailSubjectContains__c = '';
                caseRouting1.EmailBodyContains__c = '';     
                caseRouting1.SenderEmailContains__c = '';
                caseRouting1.InboundEmailAddress__c = 'GCSNATestSF_TEST1@monster.com';
                caseRouting1.SFDC_Routing_Address__c = 'gcsnatestsf';
        		caseRouting1.AutoResponseTemplate__c = et.DeveloperName;
        		caseRouting1.FromAddressforAutoResponse__c = 'customerservice@monster.com';
                insert CaseRouting1;
        
                caseRouting2.OwnerId = Owner2.Id;
                caseRouting2.RecordTypeId = emailRecordTypeId;
                caseRouting2.SenderEmailContains__c = 'Test@test.com';
                caseRouting2.InboundEmailAddress__c = 'GCSNATestSF_TEST1@monster.com';
                caseRouting2.SFDC_Routing_Address__c = 'gcsnatestsf';
        		caseRouting2.AutoResponseTemplate__c = et.DeveloperName;
        		caseRouting2.FromAddressforAutoResponse__c = 'customerservice@monster.com';
                insert CaseRouting2;
        
                
        
        		

                EmailMessage em = TestDataSetupUtility.createEmailMessage(cse.Id, true, false);
                em.fromaddress = 'Test1@test.com'; // try to force a mismatch, to match the inner catchall rule instead of caseRouting2
                em.toaddress = 'GCSNATestSF_TEST1@monster.com';
                em.subject = 'Test Subject';
                em.textbody = 'Test Body';
                
                insert em;

                List<Case> listCase = [Select id, OwnerId, Priority From Case Where Id = :cse.Id];
                System.assertEquals(listCase[0].OwnerId,Owner1.Id); 
        		                
                Test.stopTest();
        }



}