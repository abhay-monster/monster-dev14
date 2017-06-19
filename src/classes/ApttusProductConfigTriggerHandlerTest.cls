@isTest 

public with sharing class ApttusProductConfigTriggerHandlerTest {

static Apttus_Config2__ProductConfiguration__c newProductConfiguration ; 
static User testuser;

static {
	Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
    testUser = TestDataSetupUtility.createTestUser('Test ', 'System Admin', p.Id);
    insert testuser;

	newProductConfiguration = new Apttus_Config2__ProductConfiguration__c(Apttus_Config2__Status__c='New');

	insert newProductConfiguration;

}

static testMethod void onAfterUpdateTest() {

		System.runAs(testUser){
			newProductConfiguration.Apttus_Config2__Status__c = 'Finalized';

			Test.startTest();
			
			update newProductConfiguration;

			Test.stopTest();

			Apttus_Config2__ProductConfiguration__c assertProductConfiguration = [SELECT Id, Apttus_Config2__Status__c FROM Apttus_Config2__ProductConfiguration__c WHERE Id=: newProductConfiguration.Id];

			System.assertEquals(assertProductConfiguration.Apttus_Config2__Status__c, 'Finalized');
		}
	}
}