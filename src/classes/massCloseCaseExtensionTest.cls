@isTest
public with sharing class massCloseCaseExtensionTest {
 // TKOM: added for S-435311  
 // test class for massCloseCase controller extension
 // 
 // reference materials:
 // http://blog.jeffdouglas.com/2010/06/02/testing-salesforce-com-controller-extensions/
 // https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/apex_pages_standardsetcontroller.htm
 // 
 
    static massCloseCaseExtension ext;
    static PageReference pref;
    
    @testSetup
    static void preTestSetup(){
        system.debug('In method massCloseCaseExtensionTest::preTestSetup()');
        Profile pAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Profile pNonAdmin = [SELECT Id FROM Profile WHERE Name = 'Service Rep (EU)' LIMIT 1];
            
        //User usr =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', pAdmin.Id);
        User usrNonAdmin =  TestDataSetupUtility.createTestUser('Test ', ' ServiceRep', pNonAdmin.Id);
        insert new List<User>{usrNonAdmin};
        Personal_Settings__c personalSettings = new Personal_Settings__c();
        personalSettings.trigger_case__c = false;
        personalSettings.trigger_account__c = false;
        insert personalSettings;
            	
        Case cse1 = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usrNonAdmin.Id); 
        cse1.Status = 'Open';
        cse1.SubStatus__c = 'Open';
        insert cse1;
        system.debug('Inserted test case 1: ' + cse1.Id);    	
        
        Case cse2 = TestDataSetupUtility.createTestNewAccountRequestCase('Europe',usrNonAdmin.Id); 
        cse2.Status = 'Open';
        cse2.SubStatus__c = 'Open';
        insert cse2;
        system.debug('Inserted test case 2: ' + cse2.Id);
        
        //List<Case> caseList = {cse1,cse2};
        		
    }
    
	static testMethod void testMassUpdateCases() {
		// the page should allow users to save the records as long as there is 1 or more selected record in the list, and they pick a value for Status and Substatus
    	system.debug('In method massCloseCaseExtensionTest::testMassUpdateCases()');
        preTestSetup();
	
    	List<Case> caseList = [Select id, Status, SubStatus__c From Case limit 2]; // should return the 2 cases created above
    	system.debug('Add records to caseList: ' + caseList.size());
     
    	ApexPages.StandardSetController con = new ApexPages.StandardSetController(caseList);
		con.setSelected(caseList); // set the cases to be selected on the list view
        ext = new massCloseCaseExtension(con);
    	system.debug('ext.getListViewRecordsSize() = '+ ext.getListViewRecordsSize());
    
    	Test.startTest();
    	system.assertEquals(caseList.size(), ext.getListViewRecordsSize());
     
    	pref = Page.massCloseCase;
    	//pref.getParameters().put('id',masterObject.id);
    	Test.setCurrentPage(pref);
     
    	ext.getSubStatuses();
        pref.getParameters().put('subStatus', 'Resolved'); 
		
        try {
        	if(Test.isRunningTest()){ ext.verifySubStatus();}
        } 
        catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            System.assert(e.getMessage().contains('Please choose a valid SubStatus, you cannot use'), 'message=' + e.getMessage());
        }
  	 	pref = ext.save();
    
     	// asserts - check the new status/substatus of the cases in the list
     
		Test.stopTest();
    }

	static testMethod void testNoSubStatusSelected() {
    	// The page should disable the Save button and display an error message if "--None--" is selected as the substatus on the page
    	system.debug('In method massCloseCaseExtensionTest::testNoSubStatusSelected()');
        preTestSetup();
		List<Case> caseList = [Select id, Status, SubStatus__c From Case limit 2]; // should return the 2 cases created above
    	system.debug('Add records to caseList: ' + caseList.size());
             
     
    	ApexPages.StandardSetController con = new ApexPages.StandardSetController(caseList);
		con.setSelected(caseList); // set the cases to be selected on the list view
        ext = new massCloseCaseExtension(con);
    	system.debug('ext.getListViewRecordsSize() = '+ ext.getListViewRecordsSize());
    
    	Test.startTest();
     	system.assertEquals(caseList.size(), ext.getListViewRecordsSize());
     	
    	pref = Page.massCloseCase;
    	//pref.getParameters().put('id',masterObject.id);
    	Test.setCurrentPage(pref);
    
    	
        pref.getParameters().put('subStatus', '--None--'); 
		try {
        	if(Test.isRunningTest()){ ext.verifySubStatus();}
        } 
        catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            System.assert(e.getMessage().contains('Please choose a valid SubStatus, you cannot use'), 'message=' + e.getMessage());
        }
        
    	pref = ext.save();
    
     	// asserts - check that error was thrown - save button should be disabled when no SubStatus selected
     
    	Test.stopTest();

    }

	static testMethod void testNoRecordsSelected() {
    	// The page should disable the Save button and display an error message if no records were checked on the list view before clicking the Mass Close Cases button
    	system.debug('In method massCloseCaseExtensionTest::testNoRecordsSelected()');
        preTestSetup();
		List<Case> caseList = new List<Case>() ; // no cases in the list
    	system.debug('Add records to caseList: ' + caseList.size());
             
     
    	ApexPages.StandardSetController con = new ApexPages.StandardSetController(caseList);
		con.setSelected(caseList); // set the cases to be selected on the list view
        ext = new massCloseCaseExtension(con);
    	system.debug('ext.getListViewRecordsSize() = '+ ext.getListViewRecordsSize());
    
    	
    	Test.startTest();
     	system.assertEquals(caseList.size(), ext.getListViewRecordsSize());
    	pref = Page.massCloseCase;
    	//pref.getParameters().put('id',masterObject.id);
    	Test.setCurrentPage(pref);
    
    	pref.getParameters().put('subStatus', 'Resolved'); 
    	
		try {
        	if(Test.isRunningTest()){ ext.verifySubStatus();}
        } 
        catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            System.assert(e.getMessage().contains('Please choose a valid SubStatus, you cannot use'), 'message=' + e.getMessage());
        }
        
    	pref = ext.save();
    
     	// asserts - check that error was thrown - save button should be disabled when no SubStatus selected
     
    	Test.stopTest();
    
    }
}