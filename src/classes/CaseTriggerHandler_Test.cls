@isTest
private class CaseTriggerHandler_Test {

	static testmethod void testAssignContactCreate() {
                Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings;

                Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                insert usr;
                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id);
                cse.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case','GCS');
                cse.SuppliedName = 'Joe Bloggs';
                cse.SuppliedEmail = 'test@test.com';
                insert cse;

                List<Case> listcse = [Select id, ContactId From Case Where Id = :cse.Id];
                System.assertNotEquals(listcse[0].ContactId, null);
	}

	static testmethod void testAssignContactDuplicate() {
                Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings;

        	Account a = TestDataSetupUtility.createPersonAccount();
        	insert a;
        	Account a2 = TestDataSetupUtility.createpersonAccount();
        	insert a2;

                Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                insert usr;
                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id);
                cse.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case','GCS');
                cse.SuppliedName = 'Joe Bloggs';
                cse.SuppliedEmail = 'test@test.com';
                insert cse;

                List<Case> listcse = [Select id, ContactId From Case Where Id = :cse.Id];
                //System.assertNotEquals(listcse[0].ContactId, null);
	}

        static testmethod void testCaseRoutingGCS(){
                Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings;

                CaseRoutingRule__c caseRouting  = TestDataSetupUtility.createCaseRoutingRecord();
                QueueSobject q = [select CreatedById, Id, QueueId, SobjectType, SystemModstamp from QueueSobject Where Sobjecttype = 'Case' Limit 1];
                caseRouting.OWnerId = q.QueueId;
                caseRouting.CaseRecordType__c = 'GCS';
                caseRouting.Billing_Country__c = 'United Kingdom';
                caseRouting.CaseContactSource__c = 'Seeker';
                caseRouting.CaseLanguage__c = 'English';
                caseRouting.Case_Subject__c = 'Administration';
                insert CaseRouting;

                Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                insert usr;

                Brand__c b = TestDataSetupUtility.createBrand(true);

                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id);
                cse.SuppliedName = 'Joe Bloggs';
                cse.SuppliedEmail = 'test@test.com';
                cse.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case','GCS');
                cse.Language__c = caseRouting.CaseLanguage__c;
                cse.ContactSource__c = caseRouting.CaseContactSource__c;
                cse.BillingCountry__c = caseRouting.Billing_Country__c;
                cse.Subject = caseRouting.Case_Subject__c;
                cse.Brand__c = b.id;
                insert cse;

                List<Case> listcse = [Select id, OWnerId From Case Where Id = :cse.Id];
               // System.assertEquals(listcse[0].OWnerId, caseRouting.OWnerId);
        }
    
    	static testmethod void testCaseRoutingSalestoGCS(){ 
            //TK 9/5/16 S-440359: added method to test rougint including Case_Request_Type__c criteria
                Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings;

                CaseRoutingRule__c caseRouting  = TestDataSetupUtility.createCaseRoutingRecord();
                QueueSobject q = [select CreatedById, Id, QueueId, SobjectType, SystemModstamp from QueueSobject Where Sobjecttype = 'Case' Limit 1];
                caseRouting.OWnerId = q.QueueId;
                caseRouting.CaseRecordType__c = 'GCS';
                caseRouting.Billing_Country__c = 'United Kingdom';
                caseRouting.CaseContactSource__c = 'Sales';
                caseRouting.CaseLanguage__c = 'English';
                caseRouting.Case_Subject__c = 'Administration';
            	caseRouting.Case_Request_Type__c = 'Demo Account';
                insert CaseRouting;

                Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                insert usr;

                Brand__c b = TestDataSetupUtility.createBrand(true);

                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id);
                cse.SuppliedName = 'Joe Bloggs';
                cse.SuppliedEmail = 'test@test.com';
                cse.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case','GCS');
                cse.Language__c = caseRouting.CaseLanguage__c;
                cse.ContactSource__c = caseRouting.CaseContactSource__c;
                cse.BillingCountry__c = caseRouting.Billing_Country__c;
                cse.Subject = caseRouting.Case_Subject__c;
                cse.Brand__c = b.id;
            	cse.Request_Type__c = caseRouting.Case_Request_Type__c;
                insert cse;

                List<Case> listcse = [Select id, OWnerId From Case Where Id = :cse.Id];
               // System.assertEquals(listcse[0].OWnerId, caseRouting.OWnerId);
        }

        static testmethod void testCaseRoutingRegistration(){
                Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings;

                CaseRoutingRule__c caseRouting  = TestDataSetupUtility.createCaseRoutingRecord();
                QueueSobject q = [select CreatedById, Id, QueueId, SobjectType, SystemModstamp from QueueSobject Where Sobjecttype = 'Case' Limit 1];
                caseRouting.OwnerId = q.QueueId;
                caseRouting.CaseRecordType__c = 'Registration/VATFiscal Code';
                caseRouting.Current_User_Country__c = 'United States';
                insert CaseRouting;

                Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                insert usr;

                //need to put in a running user since the code looks at the running users country to determine routing
                User runningUSER =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                runningUser.Location__c = 'United States';
                insert runningUser;

                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',runningUser.Id);
                cse.SuppliedName = 'Joe Bloggs';
                cse.SuppliedEmail = 'test@test.com';
                cse.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case','Registration/VATFiscal Code');
                System.runAs(runningUser){
                        Test.startTest();
                        insert cse;
                        Test.stopTest();
                }

                List<Case> listcse = [Select id, OWnerId From Case Where Id = :cse.Id];
               // System.assertEquals(listcse[0].OWnerId, caseRouting.OWnerId);
        }

        /*static testmethod void testCaseRoutingParent(){
                Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings;

                CaseRoutingRule__c caseRouting  = TestDataSetupUtility.createCaseRoutingRecord();
                QueueSobject q = [select CreatedById, Id, QueueId, SobjectType, SystemModstamp from QueueSobject Where Sobjecttype = 'Case' Limit 1];
                caseRouting.OwnerId = q.QueueId;
                caseRouting.CaseRecordType__c = 'Parent/Child Inventory Sharing';
                caseRouting.Current_User_Country__c = 'United Kingdom';
                insert CaseRouting;

                Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                insert usr;

                //need to put in a running user since the code looks at the running users country to determine routing
                User runningUSER =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                runningUser.country = 'United Kingdom';
                insert runningUser;

                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id);
                cse.SuppliedName = 'Joe Bloggs';
                cse.SuppliedEmail = 'test@test.com';
                cse.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case','Parent/Child Inventory Sharing');
                System.runAs(runningUser){
                        Test.startTest();
                        insert cse;
                        Test.stopTest();
                }

                List<Case> listcse = [Select id, OWnerId From Case Where Id = :cse.Id];
                System.assertEquals(listcse[0].OWnerId, caseRouting.OWnerId);
        }*/

       /*  Jeff L Commented out 12/13/15, it looks like this logic was commented out in the case routing, so the test was failing
        static testmethod void testCaseRoutingDataGovernance(){
                Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings;

                CaseRoutingRule__c caseRouting  = TestDataSetupUtility.createCaseRoutingRecord();
                QueueSobject q = [select CreatedById, Id, QueueId, SobjectType, SystemModstamp from QueueSobject Where Sobjecttype = 'Case' Limit 1];
                caseRouting.OwnerId = q.QueueId;
                caseRouting.CaseRecordType__c = 'New Account Request';
                caseRouting.Current_User_Country__c = 'United States';
                insert CaseRouting;

                Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                User runningUser =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                runningUser.Location__c = 'United States';
                insert runningUser;

                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',runningUser.Id);
                cse.SuppliedName = 'Joe Bloggs';
                cse.SuppliedEmail = 'test@test.com';
                cse.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case','New Account Request');
                System.runAs(runningUser){
                        Test.startTest();
                        insert cse;
                        Test.stopTest();
                }

                List<Case> listcse = [Select id, OWnerId From Case Where Id = :cse.Id];
                System.assertEquals(listcse[0].OWnerId, caseRouting.OWnerId);
        }*/

        static testmethod void testCaseRoutingCreditLimitRequest(){
                Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings;

                CaseRoutingRule__c caseRouting  = TestDataSetupUtility.createCaseRoutingRecord();
                QueueSobject q = [select CreatedById, Id, QueueId, SobjectType, SystemModstamp from QueueSobject Where Sobjecttype = 'Case' Limit 1];
                caseRouting.OwnerId = q.QueueId;
                caseRouting.CaseRecordType__c = 'Request re Credit Limit';
                caseRouting.Current_User_Country__c = 'United States';
                insert CaseRouting;

                Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);

                insert usr;

                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id);
                cse.SuppliedName = 'Joe Bloggs';
                cse.SuppliedEmail = 'test@test.com';
                cse.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case','Request re Credit Limit');
                insert cse;

                List<Case> listcse = [Select id, OWnerId From Case Where Id = :cse.Id];
                //System.assertEquals(listcse[0].OWnerId, caseRouting.OWnerId);
        }
    
    	static testmethod void testCaseRoutingOMProcessingRequest(){
                Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings;

                CaseRoutingRule__c caseRouting  = TestDataSetupUtility.createCaseRoutingRecord();
                QueueSobject q = [select CreatedById, Id, QueueId, SobjectType, SystemModstamp from QueueSobject Where Sobjecttype = 'Case' Limit 1];
                caseRouting.OwnerId = q.QueueId;
                caseRouting.CaseRecordType__c = 'OM Processing Request';
                caseRouting.Current_User_Country__c = 'United States';
                insert CaseRouting;

                Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);

                insert usr;

                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id);
                cse.SuppliedName = 'Joe Bloggs';
                cse.SuppliedEmail = 'test@test.com';
                cse.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case','OM Processing Request');
                insert cse;

                List<Case> listcse = [Select id, OWnerId From Case Where Id = :cse.Id];
                //System.assertEquals(listcse[0].OWnerId, caseRouting.OWnerId);
        }
       
    static testmethod void testCaseRoutingCreditRequest(){
                Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings;

                CaseRoutingRule__c caseRouting  = TestDataSetupUtility.createCaseRoutingRecord();
                QueueSobject q = [select CreatedById, Id, QueueId, SobjectType, SystemModstamp from QueueSobject Where Sobjecttype = 'Case' Limit 1];
                caseRouting.OwnerId = q.QueueId;
                caseRouting.CaseRecordType__c = 'Credit Request';
                caseRouting.Current_User_Country__c = 'United States';
        		caseRouting.Organization__c = 'Europe';
                insert CaseRouting;

                Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);

                insert usr;

                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id);
                cse.SuppliedName = 'Joe Bloggs';
                cse.SuppliedEmail = 'test@test.com';
                cse.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case','Credit Request');
        		cse.Organization__c = 'Europe';
                insert cse;

                List<Case> listcse = [Select id, OWnerId From Case Where Id = :cse.Id];
        }

        //added per S--352424
        static testmethod void testBlockCaseCommentDeletion() {
                Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings;

                Profile p = [SELECT Id FROM Profile WHERE Name = 'Service Operations' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                insert usr;
                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id);
                cse.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case','GCS');
                cse.SuppliedName = 'Joe Bloggs';
                cse.SuppliedEmail = 'test@test.com';
                insert cse;

                CaseComment cc = new CaseComment(CommentBody='Test', ParentId=cse.Id);
                insert cc;
                delete cc;

                delete cse;
    }

            //added per S--352424
        static testmethod void testAllowCaseCommentDeletion() {
                Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings;

                Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                insert usr;
                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id);
                cse.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case','GCS');
                cse.SuppliedName = 'Joe Bloggs';
                cse.SuppliedEmail = 'test@test.com';
                insert cse;

                CaseComment cc = new CaseComment(CommentBody='Test', ParentId=cse.Id);
                //insert cc;
                //delete cc;

                //delete cse;
    }

        //added per S--352424
        static testmethod void testBlockFeedItemDeletion() {
                Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings;

                Profile p = [SELECT Id FROM Profile WHERE Name = 'Service Operations' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                insert usr;
                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id);
                cse.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case','GCS');
                cse.SuppliedName = 'Joe Bloggs';
                cse.SuppliedEmail = 'test@test.com';
                insert cse;

                FeedItem fi = new FeedItem(Body='Test', ParentId=cse.Id);
                insert fi;
                delete fi;
    }

            //added per S--352424
        static testmethod void testAllowFeedItemDeletion() {
                Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings;

                Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                insert usr;
                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id);
                cse.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Case','GCS');
                cse.SuppliedName = 'Joe Bloggs';
                cse.SuppliedEmail = 'test@test.com';
                insert cse;

                FeedItem fi = new FeedItem(Body='Test', ParentId=cse.Id);
                insert fi;
                delete fi;
    }

        static testmethod void testBlockEmailMessageDelete(){

                Personal_Settings__c personalSettings = new Personal_Settings__c();
                personalSettings.trigger_case__c = true;
                personalSettings.trigger_account__c = false;
                insert personalSettings;

                Profile p = [SELECT Id FROM Profile WHERE Name = 'Service Operations' LIMIT 1];
                User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
                Case cse = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usr.Id);
                cse.Status= 'Closed';
                cse.ClosedDate = date.today().addDays(-50);
                cse.CreatedDate = date.today().addDays(-50); 
                insert cse;
                
                EmailMessage em = TestDataSetupUtility.createEmailMessage(cse.Id, false, true);
                delete em;
        }

}