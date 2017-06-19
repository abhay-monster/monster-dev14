/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestExceptionHandler {

    static testMethod void myUnitTest1() {
        // TO DO: implement unit test
        
        
    }
    
    static Lead ld;
	static Account acc;
	static Opportunity opp;
	static User usr;
	static {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
   	 	usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
   	 	insert usr;
		ld = TestDataSetupUtility.createTestLead();
		acc = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        insert acc;
        opp = TestDataSetupUtility.createTestOpportunity('Test Opportunity', acc.Id);
   		insert opp;
	}
	static testMethod void testLeadTrigger1(){
		try{
		system.runAs(usr) {
			Test.startTest();
			insert ld;
			ld.street = 'A 72';
			//ld.IsConverted = true;
			//ld.convertedAccountId = acc.Id;
			//ld.convertedOpportunityId = opp.Id;
			update ld;
			Database.LeadConvert lc = new database.LeadConvert();
			lc.setLeadId(ld.id);
			lc.setDoNotCreateOpportunity(true);
			lc.setConvertedStatus('Converted');

			Database.LeadConvertResult lcr = Database.convertLead(lc);
			System.assert(lcr.isSuccess());

			Test.stopTest();
		}
		}
		catch(Exception e){
			ExceptionHandler.GetExceptionDetailsAsString(e);
		}
	}
}