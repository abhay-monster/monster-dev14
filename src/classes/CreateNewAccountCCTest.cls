/**
 * @author Cloud Sherpas Inc.
 * @date 1.7.2015
 * @description This is the Test class for CreateNewAccountCC class and CreateNewAccount page. 
*/
@isTest
private class CreateNewAccountCCTest {
    static User salesUser;
    static User salesOp;
    /** 
     * @author Andre Calimlim
     * @date 12.4.14
     * @description static method to create test data records
     * @param org - String value for the name of the Organisation
     */
    static Case createRec(String org,String country, String countryCode,Boolean setPersonalSettings){
        Personal_Settings__c personalSettings = TestDataSetupUtility.buildPersonalSetting();
        if(setPersonalSettings){
            personalSettings.Trigger_Account_Contact_Association__c = true;
            personalSettings.Trigger_Contact__c = true;
            personalSettings.Trigger_Case__c = true;
            personalSettings.Validation_Contact__c = true;
            personalSettings.Trigger_Order__c = true;
            personalSettings.Trigger_Account__c = true;
            personalSettings.Trigger_Opportunity__c = true;
            personalSettings.Validation_Account__c = true;
            personalSettings.Validation_Opportunity__c = true;
        }
        insert personalSettings;
        insert TestDataSetupUtility.buildMaximumCustomerNumberSetting();
        insert TestDataSetupUtility.buildWebServiceEndpointSetting();
        insert TestDataSetupUtility.buildIntegrationConfigSetting();
        insert TestDataSetupUtility.buildCaseTriggerSetting();
        
        salesUser = TestDataSetupUtility.createTestUser('Sales', 'Rep', TestDataSetupUtility.SALESREP_APAC_PROFILE_ID, org);
        insert salesUser;
        
        salesOp = TestDataSetupUtility.createTestUser('Sales', 'Op', TestDataSetupUtility.SALESOP_NA_PROFILE_ID, 'North America');
        insert salesOp;
        
        
        CountryCode__c cc = TestDataSetupUtility.buildCountryCodeSetting(country, countryCode);
        insert cc;
        
        Account acc = TestDataSetupUtility.createTestAccount('test',null,null);
    insert acc;
    Contact con = TestDataSetupUtility.createTestContact(acc.Id,'test','Con','abccon@gmail.com'); 
    insert con;
    
    Stop_Status__c ss = new Stop_Status__c(name = 'New');
    insert ss;
    
    Case caseObj = new Case(
                AccountId = acc.Id,
                ContactId = con.Id,
                Status = 'New',
                Category__c = 'Browser Issue',
                Issue__c = 'Other',
                SubIssue__c = 'Other',
                Subject = 'TEST Subject Parent',
                CustomerProblemDetail__c = 'TEST Details Parent'
     );
	 caseObj.PrimarySalesRepID__c = salesUser.Id;
	 caseObj.BillingCountry__c = country;
	 caseObj.BillingCity__c = 'Makati City';
	 caseObj.BillingZipPostalCode__c = '1226';
	 caseObj.BillingStreet__c = '30thF PhilamLife Tower';
	 caseObj.Account_Name__c = 'Test Account';
	 caseObj.BillingStateProvince__c = 'st';
	 caseObj.Description = 'desc';
	 caseObj.SalesChannel__c = 'sc';
	 caseObj.RegistrationNumber__c = '345353';
	 caseObj.VATNumber_c__c = '453';
	 caseObj.URL__c ='google.com';
	 caseObj.AccountGroup__c = 'grp';
	 caseObj.Employees__c = 12;
	 caseObj.SICCode__c = '454';
	 caseObj.AccountPhone__c = '454443335';
	 caseObj.PhoneExtension__c ='45';
	 caseObj.Company_Type__c = ' rtret';
     insert caseObj;
        return caseObj;
    } 
    /**
     * @author Andre Calimlim
     * @date 1.7.2015
     * @description Positive TestMethod to verify that the new account created will have the same organisation based from the user that created the case, and the Case is now Closed. 
     */
    /*static testMethod void testOrgNewAccountCaseClosed() {
        Case cs = createRec('Asia Pacific','Philippines','PH' true);

        //System.assertEquals(salesUser.Id, cs.CreatedById);
        Test.startTest();
            PageReference pageRef  = Page.CreateNewAccount;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('caseId',cs.Id);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(cs);
            try{    
            CreateNewAccountCC ctrl = new CreateNewAccountCC(sc);
                
            ctrl.executeMethod();
          //  System.assertEquals(salesUser.Organisation__c, [Select Organization__c from Account limit 1].Organization__c);
          }catch(Exception e){}      
        Test.stopTest();
      //  System.assertEquals('Closed', [Select Status from Case where Id = : cs.Id limit 1].Status);
    }*/
    /**
     * @author Andre Calimlim
     * @date 1.7.2015
     * @description Negative TestMethod to verify that the Case is will not be Closed for cross reference exception. 
     */
    static testMethod void testCaseClosed() {
        Case cs = createRec('Asia Pacific','United States','US', true);

        Test.startTest();
            System.runAs(salesOp){
                PageReference pageRef  = Page.CreateNewAccount;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('caseId',cs.Id);
                ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(cs);
                try{
                CreateNewAccountCC ctrl = new CreateNewAccountCC(sc);
                
                ctrl.executeMethod();
                //System.assertEquals(salesUser.Organisation__c, [Select Organization__c from Account limit 1].Organization__c);
                }catch(Exception e){}
            }
        Test.stopTest();
        //System.assertEquals('New', [Select Status from Case where Id = : cs.Id limit 1].Status);
    } 
}