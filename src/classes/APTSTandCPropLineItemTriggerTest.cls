@isTest
public class APTSTandCPropLineItemTriggerTest {

    
    
    static testMethod void testAPTSTandCPropLineItemTrigger(){
        Apttus_Proposal__Proposal__c proposal = null;
        Account acct = TestDataSetupUtility.createTestAccountWithShippingAndBilling('TestAcct_28_07_15');
        insert acct;
        Contact con = TestDataSetupUtility.createTestContact(acct.Id, 'Test_Last', 'Test_First', 'test@test.com');
        insert con;
        
       //create Opportunity
       Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp', acct.Id);
       opp.RecordTypeId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'GCS Opportunity');
       insert opp;
            
       proposal = TestDataSetupUtility.createProposal('TEST_PROP_28_07_15', acct.Id, opp.Id, 'test', false);
       insert proposal;
        
       //Create product2
       Product2 product = TestDataSetupUtility.createProduct('Test product5', false); 
       product.Convert_From__c = true;
       product.APTPS_Rev_Share__c=10;
       product.APTPS_Rev_Share_Type__c='Net';
       insert product;
       
       Apttus_Config2__PriceList__c priceList = TestDataSetupUtility.createPriceList('USD Price List', false);
       insert priceList; 
               
       Apttus_Config2__ProductConfiguration__c config = TestDataSetupUtility.createTestProductConfig(proposal,acct,priceList);
       config.Apttus_Config2__Status__c = 'Saved';
       insert config;
       config.Apttus_Config2__Status__c = 'Finalized';
       update config;
       
       
       Apttus_Config2__LineItem__c lineitem = TestDataSetupUtility.createLineItemApttus(config.ID);
       insert lineitem;
       
       Apttus_Config2__ProductAttributeValue__c pav = new Apttus_Config2__ProductAttributeValue__c();
        pav.Apttus_Config2__LineItemId__c = lineitem.ID;
        pav.CurrencyIsoCode = 'USD';
        pav.Product_Type__c = 'Sourcing Services-GL';
        insert pav;
        
       Apttus_Proposal__Proposal_Line_Item__c propLineItem = New Apttus_Proposal__Proposal_Line_Item__c();
       propLineItem.Apttus_QPConfig__ConfigurationId__c = config.Id;
       propLineItem.Apttus_QPConfig__NetPrice__c=3400;
       propLineItem.Apttus_QPConfig__BaseExtendedPrice__c=2040;
       propLineItem.Apttus_Proposal__Proposal__c =proposal.Id; 
       propLineItem.Apttus_QPConfig__OptionId__c = null;
       propLineItem.Rev_Share_Type__c='Net';
       propLineItem.Apttus_QPConfig__OptionId__c=product.ID;
       propLineItem.Rev_Share__c=10;
       propLineItem.Apttus_QPConfig__DerivedFromId__c = lineitem.Id;

       insert propLineItem;
        
        Terms_and_Conditions_Proposal_Line_Item__c TandC = new Terms_and_Conditions_Proposal_Line_Item__c();
        
        //cretate a new Terms and condition Proposal Line Item record for new terms and condition.
        TandC.Proposal_Line_Item__c = propLineItem.Id;
        TandC.Term_text__c = 'Test term text';
        insert TandC;
        
    }
}