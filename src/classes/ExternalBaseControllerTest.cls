@isTest
private class ExternalBaseControllerTest{
    private static testMethod void  testController(){
        Brand__c brand = new Brand__c(Name='Test Brand', Tabs__c = 'tab1:tab2', Language__c='English');
        insert brand;
        Contact_Us_Options__c con = new Contact_Us_Options__c(Brand__c = brand.Id,Active__c = True,
        Display_Twitter_Handle__c= True,Display_Text_Chat_Link__c= True,Display_Phone_Number__c= True,
        Display_Hours_of_Operation__c= True);
        insert con;
        Test.startTest();
        Apexpages.currentpage().getparameters().put('Brand','Test Brand');
        Apexpages.currentpage().getparameters().put('Lang',brand.Language__c);
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(brand);
        externalBaseController ctrl = new externalBaseController(stdCtrl);
        ctrl.contactUs();
        
        Test.stopTest();
    
    }

}