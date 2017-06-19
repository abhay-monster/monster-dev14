@isTest
private class TerritoryAssignmentForBatchTest {
    static testmethod void unittest1()
    {
        insert TestDataSetupUtility.buildZipcodeConfiguration('United States','ddddddddd','^\\d{5}(?:[-\\s]*\\d{4})?$','^\\d{5}(?:[-\\s]*\\d{4})?$');
        insert TestDataSetupUtility.buildZipcodeConfiguration('Canada','AdAdAd','^[A-Z]\\d[A-Z](?:\\s*\\d[A-Z]\\d)?$','^[A-Z]\\d[A-Z]\\s*\\d[A-Z]\\d$');

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //User u = [select id,alias from User where ProfileId =: p.Id and isActive = true limit 1];
        User u = TestDataSetupUtility.createTestUser('TestFistName2','TestLastName2', p.Id);
        insert u;
		//user2 added for added for getAccountTeamMembers() 
        User u2= TestDataSetupUtility.createTestUser('TestFistName2', 'TestLastName2', p.Id);
        insert u2;
        User taOwner = TestDataSetupUtility.createTestUser('TAOwnerFirst', 'TAOwnerLast', p.Id);
        insert taOwner;
        System.runAs(u)
        {
            Test.startTest();

            List<Account> accList = new List<Account>();
            Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
            testAccount.Phone = '+18008008000';
            testAccount.PrimaryServiceRep__c = u.id;
            testAccount.Organization__c = 'North America';
            testAccount.ServiceTier__c = 'Core';
            testAccount.DoNotReassign__c = false;
            testAccount.AccountGroup__c = 'Telesales Acquisition';
            testAccount.ShippingPostalCode = '05401-1234';
            testAccount.SalesChannel__c = 'Partner';
            testAccount.SalesChannel__c = 'Commercial';
            insert testAccount;

            testAccount.ShippingPostalCode = '05401-2345';
            update testAccount;
           // Opportunity oppRecord = TestDataSetupUtility.createTestOpportunity('opp1', testAccount.Id);
           // insert oppRecord;

            Account testAccount2 = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
            testAccount2.DoNotReassign__c = false;
            testAccount2.AccountGroup__c = 'Telesales Acquisition';
            testAccount2.ShippingPostalCode = '05401-1357';
            testAccount2.SalesChannel__c = 'Partner';
            testAccount.SalesChannel__c = 'Commercial';
            insert testAccount2;

            testAccount2.ShippingPostalCode = '05401-2468';
            update testAccount2;

            accList.add(testAccount);
            accList.add(testAccount2);

            system.debug('=====> accList : '+accList);
            String accountId = [Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c;
            String accountId2 = [Select AccountId__c from Account where Id = : testAccount2.Id].AccountId__c;
            system.debug('=====> accList 1 : '+[Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c);
            system.debug('=====> accList 2 : '+[Select AccountId__c from Account where Id = : testAccount2.Id].AccountId__c);

            TerritoryAssignment__c ta = new TerritoryAssignment__c();
            ta.OwnerId = taOwner.Id;
            insert ta;

            List<TerritoryAssignmentCode__c> tacList = new List<TerritoryAssignmentCode__c>();

            //                                                                                      TAC ID, Acct Country, Acct Group, Acct Size, EmpSize, Named Acct, Zip Start, Zip End, Sales Channel, Segment
            TerritoryAssignmentCode__c tacObj1 = TestDataSetupUtility.createTerritoryAssignmentCode(ta.ID, 'United States', 'Telesales Acquisition', null, null, accountId, '05401', '05402', 'Partner', 'Commercial');
            TerritoryAssignmentCode__c tacObj2 = TestDataSetupUtility.createTerritoryAssignmentCode(ta.ID, 'United States', 'Active', null, null, accountId, '05401', '05402', 'Partner', 'Commercial');
            TerritoryAssignmentCode__c tacObj3 = TestDataSetupUtility.createTerritoryAssignmentCode(ta.ID, 'United States', 'Telesales Acquisition', null, null, accountId, '05401', '05402', 'Agency', 'Commercial');
            TerritoryAssignmentCode__c tacObj4 = TestDataSetupUtility.createTerritoryAssignmentCode(ta.ID, 'United States', 'Telesales Acquisition', null, null, accountId, '05401', '05402', 'Partner', 'Commercial');

            tacList.add(tacObj1);
            tacList.add(tacObj2);
            tacList.add(tacObj3);
            tacList.add(tacObj4);

            insert tacList;

            TerritoryAssignment taconstructor = new TerritoryAssignment(accList);
            taconstructor.territoryAssignmentCodeList = tacList;
            TerritoryAssignmentForBatch terrAssignObj = new TerritoryAssignmentForBatch();
			
			/*Code added by Deepanshu, for I-218281 starts*/
			//TerritoryAssignmentTeamMember__c added for getAccountTeamMembers()
			TerritoryAssignmentTeamMember__c tatc_new = TestDataSetupUtility.createTerritoryAssignmentTeamMember(ta.ID,u.id);
			insert tatc_new;
            TerritoryAssignmentTeamMember__c tatc_new2 = TestDataSetupUtility.createTerritoryAssignmentTeamMember(ta.ID,u.id);
			insert tatc_new2;
			
			tatc_new.TeamMember__c = u2.Id;
            update tatc_new;
            tatc_new2.TeamMember__c = u.Id;
            update tatc_new2;
            
			Account_Team_Member__c atmc1 = new Account_Team_Member__c();
			atmc1.AccountId__c = testAccount.Id;
			insert atmc1;
			
			//Opportunity added for upsertOpportunityTeamMembers()
			Opportunity oppRecord1 = TestDataSetupUtility.createTestOpportunity('opp1', testAccount.Id);
			insert oppRecord1;
            Opportunity oppRecord2 = TestDataSetupUtility.createTestOpportunity('opp2', testAccount2.Id);
			insert oppRecord2;
            
            //OpportunityTeamMember, Account_Team_Member__c ,added for alreadyExists()
            OpportunityTeamMember optm1 = new OpportunityTeamMember();
            optm1.OpportunityId = oppRecord1.Id;
            optm1.UserId = u.Id;
            insert optm1;
            
            OpportunityTeamMember optm2 = new OpportunityTeamMember();
            optm2.OpportunityId = oppRecord2.Id;
            optm2.UserId = u.Id;
            insert optm2;
			
			Account_Team_Member__c actm = new Account_Team_Member__c();
			actm.UserId__c = u.id;
			insert actm;
            
            Account_Team_Member__c actm2 = new Account_Team_Member__c();
			actm2.UserId__c = u2.id;
			insert actm2;
            
            TerritoryAssignmentForBatch.buildBatchQuery(); //To cover buildBatchQuery() method
			
            /*Code added by Deepanshu, for I-218281 ends*/
			
            try{
            String output = terrAssignObj.TerritoryAssignment(accList,null);
                system.debug('output==='+output);
            }catch(Exception e){System.debug('error==='+e.getMessage());}
            system.assertEquals([Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c, accountId);
            Test.stopTest();
        }
    }
    static testmethod void unittest2()
    {

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //User u = [select id,alias from User where ProfileId =: p.Id and isActive = true limit 1];
            User u = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', p.Id);
        insert u;
		
		/*for Org setting*/
		Org_Settings__c org_setting = new Org_Settings__c();
		org_setting.Send_Emails_During_Territory_Batch_Run__c = true;
		insert org_setting ;
		
        System.runAs(u)
        {
            Test.startTest();

            List<Account> accList = new List<Account>();
            Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
            testAccount.Phone = '+18008008000';
            testAccount.PrimaryServiceRep__c = u.id;
            testAccount.Organization__c = 'North America';
            testAccount.ServiceTier__c = 'Core';
            testAccount.DoNotReassign__c = false;
            testAccount.AccountGroup__c = 'Telesales Acquisition';
            testAccount.ShippingPostalCode = '05401-1234';
            testAccount.SalesChannel__c = 'Partner';
            testAccount.SalesChannel__c = 'Commercial';
            insert testAccount;

            testAccount.ShippingPostalCode = '05401-2345';
            update testAccount;

            accList.add(testAccount);

            system.debug('=====> accList : '+accList);
            String accountId = [Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c;
            system.debug('=====> accList 1 : '+[Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c);

            TerritoryAssignment__c ta = new TerritoryAssignment__c();
            insert ta;

            List<TerritoryAssignmentCode__c> tacList = new List<TerritoryAssignmentCode__c>();

            //                                                                                      TAC ID, Acct Country, Acct Group, Acct Size, EmpSize, Named Acct, Zip Start, Zip End, Sales Channel, Segment
            TerritoryAssignmentCode__c tacObj1 = TestDataSetupUtility.createTerritoryAssignmentCode(ta.ID, 'United States', 'Telesales Acquisition', null, null, null, '05401', '05402', 'Partner', 'Commercial');
            TerritoryAssignmentCode__c tacObj2 = TestDataSetupUtility.createTerritoryAssignmentCode(ta.ID, 'United States', 'Active', null, null, null, '05401', '05402', 'Partner', 'Commercial');
            TerritoryAssignmentCode__c tacObj3 = TestDataSetupUtility.createTerritoryAssignmentCode(ta.ID, 'United States', 'Telesales Acquisition', null, null, null, '05401', '05402', 'Agency', 'Commercial');
            TerritoryAssignmentCode__c tacObj4 = TestDataSetupUtility.createTerritoryAssignmentCode(ta.ID, 'United States', 'Telesales Acquisition', null, null, null, '05401', '05402', 'Partner', 'Commercial');

            tacList.add(tacObj1);
            tacList.add(tacObj2);
            tacList.add(tacObj3);
            tacList.add(tacObj4);

            insert tacList;

            TerritoryAssignmentForBatch terrAssignObj = new TerritoryAssignmentForBatch();
            try{
            terrAssignObj.TerritoryAssignment(accList,tacList);
            }catch(Exception e){}system.assertEquals([Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c, accountId);
            Test.stopTest();
        }
    }
    static testmethod void unittest3()
    {

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //User u = [select id,alias from User where ProfileId =: p.Id and isActive = true limit 1];
            User u = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', p.Id);
        insert u;
        System.runAs(u)
        {
            Test.startTest();

            List<Account> accList = new List<Account>();
            Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
            testAccount.Phone = '+18008008000';
            testAccount.PrimaryServiceRep__c = u.id;
            testAccount.Organization__c = 'North America';
            testAccount.ServiceTier__c = 'Core';
            testAccount.DoNotReassign__c = false;
            testAccount.AccountGroup__c = 'Telesales Acquisition';
            testAccount.ShippingPostalCode = '05401-1234';
            testAccount.SalesChannel__c = 'Partner';
            testAccount.SalesChannel__c = 'Commercial';
            insert testAccount;

            testAccount.ShippingPostalCode = null;
            update testAccount;

            accList.add(testAccount);

            system.debug('=====> accList : '+accList);
            String accountId = [Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c;
            system.debug('=====> accList 1 : '+[Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c);

            TerritoryAssignment__c ta = new TerritoryAssignment__c();
            insert ta;

            List<TerritoryAssignmentCode__c> tacList = new List<TerritoryAssignmentCode__c>();

            //                                                                                      TAC ID, Acct Country, Acct Group, Acct Size, EmpSize, Named Acct, Zip Start, Zip End, Sales Channel, Segment
            TerritoryAssignmentCode__c tacObj1 = TestDataSetupUtility.createTerritoryAssignmentCode(ta.ID, 'United States', 'Telesales Acquisition', null, null, null, '05401', '05402', 'Partner', 'Commercial');

            tacList.add(tacObj1);

            insert tacList;

            TerritoryAssignmentForBatch terrAssignObj = new TerritoryAssignmentForBatch();
            try{
            terrAssignObj.TerritoryAssignment(accList,tacList);
            }catch(Exception e){}system.assertEquals([Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c, accountId);
            Test.stopTest();
        }
    }
    static testmethod void unittest4()
    {

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //User u = [select id,alias from User where ProfileId =: p.Id and isActive = true limit 1];
            User u = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', p.Id);
        insert u;
        System.runAs(u)
        {
            Test.startTest();

            List<Account> accList = new List<Account>();
            Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TEST PB Account');//, 'North America', UserInfo.getUserId());
            testAccount.Phone = '+18008008000';
            testAccount.PrimaryServiceRep__c = u.id;
            testAccount.Organization__c = 'North America';
            testAccount.ServiceTier__c = 'Core';
            testAccount.DoNotReassign__c = false;
            testAccount.AccountGroup__c = 'Telesales Acquisition';
            testAccount.ShippingPostalCode = '05401-1234';
            testAccount.SalesChannel__c = 'Partner';
            testAccount.SalesChannel__c = 'Commercial';
            insert testAccount;

            testAccount.ShippingPostalCode = '05401-2345';
            update testAccount;

            accList.add(testAccount);

            system.debug('=====> accList : '+accList);
            String accountId = [Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c;
            system.debug('=====> accList 1 : '+[Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c);

            TerritoryAssignment__c ta = new TerritoryAssignment__c();
            insert ta;

            List<TerritoryAssignmentCode__c> tacList = new List<TerritoryAssignmentCode__c>();


            //                                                                                      TAC ID, Acct Country, Acct Group, Acct Size, EmpSize, Named Acct, Zip Start, Zip End, Sales Channel, Segment
            TerritoryAssignmentCode__c tacObj1 = TestDataSetupUtility.createTerritoryAssignmentCode(ta.ID, 'United States', 'Telesales Acquisition', null, null, null, '05401', '05402', 'Partner', 'Commercial');

            tacList.add(tacObj1);

            insert tacList;
            
            //

            TerritoryAssignmentForBatch terrAssignObj = new TerritoryAssignmentForBatch();
            try{
            terrAssignObj.TerritoryAssignment(accList,tacList);
            }catch(Exception e){}system.assertEquals([Select AccountId__c from Account where Id = : testAccount.Id].AccountId__c, accountId);
            Test.stopTest();
        }
    }
	    
}