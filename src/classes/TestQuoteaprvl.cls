/*
** @author : Bhanu Devaguptapu.
** @date : 08/15/2014
** @description : Test class for Quoteaprvltrigger. 
*/
@isTest
public class TestQuoteaprvl {
static testmethod void test_Quoteaprvl(){
    Test.startTest();
    Profile p = [SELECT Id FROM Profile WHERE Name='Sales Rep (EU)']; 
    User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                      LocaleSidKey='en_US', ProfileId = p.Id, 
                      TimeZoneSidKey='America/Los_Angeles', UserName='testStuser@testorg.com');
		insert u;
        System.runAs(u) {
               Apttus_Config2__PriceList__c pricelst =new Apttus_Config2__PriceList__c();
               pricelst.Name ='USD Price List';
               insert pricelst; 
               Apttus_Proposal__Proposal__c aprvl = New Apttus_Proposal__Proposal__c();
               aprvl.Apttus_Proposal__Proposal_Name__c = 'Test opp';
               aprvl.Selling_Country__c ='United States'; 
               aprvl.Apttus_QPConfig__PriceListId__c =pricelst.Id;
               aprvl.BillingStreet__c ='123 test';
               aprvl.BillingCity__c ='test234'; 
               aprvl.BillingCountry__c ='United States';
               aprvl.BillingZipPostalCode__c = '00000'; 
            
               Account acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
               insert acc;
               Opportunity  Opp = TestDataSetupUtility.createTestOpportunity('test opp1', acc.Id);
               insert Opp;
            
               aprvl.Apttus_Proposal__Opportunity__c =opp.Id;
               insert aprvl;
               Apttus_Proposal__Proposal_Line_Item__c lnitm = New Apttus_Proposal__Proposal_Line_Item__c();
               lnitm.Apttus_QPConfig__NetPrice__c=3400;
               lnitm.Apttus_QPConfig__BaseExtendedPrice__c=2040;
               lnitm.Apttus_Proposal__Proposal__c =aprvl.Id;  
               insert lnitm;
        }
    Test.stopTest();
    }
}