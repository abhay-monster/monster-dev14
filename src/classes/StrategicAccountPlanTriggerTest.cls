// Matt Fisher Created to get enough coverage to deploy to prod org 
@IsTest
public class StrategicAccountPlanTriggerTest {
    static Account winningAcc;
    public static testmethod void createStrategicPlan() {
        
        
          //build personal settings
        Personal_Settings__c persSett = TestDataSetupUtility.buildPersonalSetting();
        
        persSett.Trigger_Account__c = false;
        persSett.Trigger_Strategic_Account_Plan__c = true;
        insert persSett;
        
        WebServiceEndpoint__c endpoint = new WebServiceEndpoint__c();
        endpoint.Endpoint__c = 'USPS Integration';
        endpoint.Name = 'USPS Integration';
        insert endpoint;
        
        IntegrationConfig__c integSett = TestDataSetupUtility.buildIntegrationConfigSetting();
        integSett.Name = 'USPS Integration';
        integSett.EndpointName__c = endpoint.Name;
        integSett.PaypalRedirectURL__c = endpoint.Endpoint__c;
        insert integSett;
        
       // CountryLimit__c cl = TestDataSetupUtility.createCountryLimit('United States', 'US', 2000, 'Staffing');
      //  insert cl;
        Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        testAccount.Organization__c = 'Europe';
        testAccount.Account_Type__c = 'Staffing';
        insert testAccount;
        

        // set custom setting for now turn off trigger
     //     Personal_Settings__c ps = new Personal_Settings__c();
     //   ps.Trigger_Strategic_Account_Plan__c = false;
      //  insert ps;
        
        // create account
      Strategic_Account_Plan__c sap = new Strategic_Account_Plan__c  ();
      sap.Account_Name__c    = testAccount.Id;
      
      insert sap;

      sap.At_Risk_Account__c = true;
      update sap;

      
    }    
    
    public static testmethod void createStrategicPlan1() {
        
        
          //build personal settings
        Personal_Settings__c persSett = TestDataSetupUtility.buildPersonalSetting();
        
        persSett.Trigger_Account__c = false;
        persSett.Trigger_Strategic_Account_Plan__c = true;
        insert persSett;
       // CountryLimit__c cl = TestDataSetupUtility.createCountryLimit('United States', 'US', 2000, 'Staffing');
      //  insert cl;
        Account testAccount = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        testAccount.Organization__c = 'Europe';
        testAccount.Account_Type__c = 'Staffing';
        testAccount.AgencyFlag__c = true;
        testAccount.CreditStatus__c = 'ok';
        insert testAccount;
        
         winningAcc = TestDataSetupUtility.createTestAccount('Winning-Account',null,null);
         winningAcc.Organization__c = 'North America';
         winningAcc.Account_Type__c = 'Reseller';
         winningAcc.AgencyFlag__c = true;
         winningAcc.CreditStatus__c = 'ok';
         insert winningAcc ;
        
        
        // set custom setting for now turn off trigger
     //     Personal_Settings__c ps = new Personal_Settings__c();
     //   ps.Trigger_Strategic_Account_Plan__c = false;
      //  insert ps;
        
        // create account
      Strategic_Account_Plan__c sap = new Strategic_Account_Plan__c  ();
      sap.Account_Name__c    = testAccount.Id;
      
      insert sap;

      
      RelatedPartner__c partner = new RelatedPartner__c();
         partner.Account__c = testAccount.Id;
         partner.partner__c = winningAcc.Id;
         partner.Role__c = 'Agency';     
         partner.AgencyType__c = 'Billing';    
         insert partner;

    }    
}