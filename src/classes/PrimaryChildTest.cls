@isTest
public class PrimaryChildTest {
	static testmethod void testPrimaryChild()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        //User u = [select id,alias from User where ProfileId =: p.Id and isActive = true limit 1];
		User u = TestDataSetupUtility.createTestUser('TestFistName', 'TestLastName', p.Id);
        insert u;              
        System.runAs(u) 
        {
            Test.startTest();
            
      		/*Personal_Settings__c personalSettings = TestDataSetupUtility.buildPersonalSetting();
      
            personalSettings.Trigger_Order__c = true;
            personalSettings.Trigger_Account__c = true;
            personalSettings.Trigger_Opportunity__c = true;
            personalSettings.Validation_Account__c = true;
            personalSettings.Validation_Opportunity__c = true;
        
        	insert personalSettings;
        */
            Account testAccount = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
            testAccount.DoNotReassign__c = true;
            insert testAccount;
            
            Order__c testOrder = new Order__c(Account__c = testAccount.id);
            insert testOrder;
            
            Xcode__c testXcode = new Xcode__c(Name = 'testXcode',Trusted__c = 'N');
            insert testXcode;
            
            XcodeAccount__c testXcodeAccout = new XcodeAccount__c(Account__c = testAccount.id,Xcode__c = testXcode.id);
            insert testXcodeAccout;
            
            XcodeAccount__c[] xAccList= new XcodeAccount__c[]{testXcodeAccout};
            
            PrimaryChild.PrimaryXCode obj = new PrimaryChild.PrimaryXCode();
            PrimaryChild.PrimaryChildRemovalConfig configObj = new PrimaryChild.PrimaryChildRemovalConfig();
            configObj.ObjectType = 'Account';
            configObj.ParentLookupField = 'OwnerId';
            configObj.PrimaryField = 'DoNotReassign__c';
            configObj.RecordTypes = 'Business_Accounts'; 
            configObj.OldChildren = new sObject[] {testAccount};
                
            obj.checkPrimaryChildRemoval(configObj);
            
            
            system.assertEquals(configObj.ObjectType, 'Account');
            
            delete testXcodeAccout;
            Test.stopTest();
        }
    }
}