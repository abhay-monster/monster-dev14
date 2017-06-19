@isTest
public with sharing class KnowledgeHomeCCTest{
    
     
       static testMethod void KnowledgeHome() {
       
       Test.StartTest();
       PageReference pageRef = Page.KnowledgeHome;
       Test.setCurrentPage(pageRef);
       pageRef.getParameters().put('type', 'test');
       pageRef.getParameters().put('tab', 'training_tutorials');

       KnowledgeHomeCC ctrl = new KnowledgeHomeCC();
      // ctrl.showTuts = true;
       ctrl.getCurrentTab();
       ctrl.getOverviewCats();
       ctrl.getTATData();
       ctrl.getCurrentState();
       system.assertNotEquals(ctrl,null);
       Test.StopTest();
       
       }
 }