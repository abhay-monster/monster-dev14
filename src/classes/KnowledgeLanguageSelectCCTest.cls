@isTest
public with sharing class KnowledgeLanguageSelectCCTest{
    
     
       static testMethod void KnowledgeLanguage() {
       
       Knowledge_Parent_Article__c knowledgeParent;
       try{
       knowledgeParent = new  Knowledge_Parent_Article__c();
       insert knowledgeParent ;
       }catch(exception e){
           system.assert(false,'Knowledge parent article not inserted');
       }
       
       Test.StartTest();
       PageReference pageRef = Page.KnowledgeLanguageSelect;
       Test.setCurrentPage(pageRef);
       pageRef.getParameters().put('Id', knowledgeParent.Id);
      
       ApexPages.Standardcontroller controller = new ApexPages.Standardcontroller(knowledgeParent );
       KnowledgeLanguageSelectCC ctrl = new KnowledgeLanguageSelectCC (controller);
       ctrl.SelectLanguage();
       ctrl.CancelLanguage();
       ctrl.DeleteCanceledRecord();
       
       system.assertNotEquals(ctrl,null);
       
       PageReference pageRef1 = Page.KnowledgeLanguageSelect;
       Test.setCurrentPage(pageRef1);
       
       ApexPages.Standardcontroller controller1 = new ApexPages.Standardcontroller(knowledgeParent );
       KnowledgeLanguageSelectCC ctrl1 = new KnowledgeLanguageSelectCC (controller1);
       ctrl1.SelectLanguage();
       ctrl1.CancelLanguage();
       ctrl1.DeleteCanceledRecord();
       
       system.assertNotEquals(ctrl1,null);
       Test.StopTest();
       
       }
    }