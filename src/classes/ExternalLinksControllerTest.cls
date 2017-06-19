@isTest

Private Class ExternalLinksControllerTest {
    static Reporting_Links__c link;
    static testmethod void testExternalLinksController(){
        prepareData();
        Test.startTest();
        ApexPages.StandardController std = new ApexPages.StandardController(link);
        ExternalLinksController controller = new ExternalLinksController(std );   
        System.assert(controller.ExternalLIst != null);  
        System.assert(controller.InternalLIst != null);    
        Test.stopTest();
    }
    
    static void prepareData(){
        link = new Reporting_Links__c ();
        link.Name = '1';
        link.External_to_SFDC__c = true;
        link.URL__c = 'www.google.com';
        insert link ;
        link = new Reporting_Links__c ();
        link.Name = '2';
        link.External_to_SFDC__c = false;
        link.URL__c = 'www.google.com';
        insert link ;
    }
    
}