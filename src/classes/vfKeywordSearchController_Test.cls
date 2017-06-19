@isTest
public class vfKeywordSearchController_Test {

    static testMethod void testKeywordSearchController(){
        Test.startTest();
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(new Apttus_Approval__Approval_Request__c());
        vfKeywordSearchController controller = new vfKeywordSearchController(stdController);
        
        
        KnowledgeArticleVersion obj = new KnowledgeArticleVersion();
        
        Brand__c brand = new Brand__c(Name='test',Active__c=true);
        insert brand;
        
        Contact_Us_Options__c contactUs = new Contact_Us_Options__c(Brand__c=brand.id,Display_Twitter_Handle__c=true,Display_Text_Chat_Link__c=true,Display_Phone_Number__c=true,Display_Hours_of_Operation__c=true,Contact_Us_Twitter_Handle__c='test',Contact_Us_Text_Chat_Link__c='test',Contact_Us_Phone_Number__c='test',Contact_Us_Hours_of_Operation__c='test',Active__c=true);
        insert contactUs;
        
        ApexPages.currentPage().getParameters().put('brandId', brand.Id);
        
        controller = new vfKeywordSearchController();
        controller.getPrevRequired();
        controller.getNextRequired();
        controller.getCurrentPageNumber();
        controller.next();
        controller.previous(); 
        //controller.contactUs();
        
        //vfKeywordSearchController.contactWrapper wrapper = new vfKeywordSearchController.contactWrapper('test', 'test1');
        
        Test.stopTest();
    }
}