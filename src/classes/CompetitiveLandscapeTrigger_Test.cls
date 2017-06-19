@isTest
Private Class CompetitiveLandscapeTrigger_Test {

     static CompetitiveLandscape__c comp;
     static List<CompetitiveLandscape__c> lstComp;
     static testMethod void testBeforeInsert() {
     
         Test.startTest();
         prepareData();
         
         CompetitiveLandscapeTriggerHandler handler = new CompetitiveLandscapeTriggerHandler(true,1);
         handler.OnAfterInsert(lstComp);
         // No functionality exists on class so we are calling method to get coverage
         map<Id,CompetitiveLandscape__c> mapCompetitiveLandscape = new map<Id,CompetitiveLandscape__c>(
                                         [Select Id,Name from CompetitiveLandscape__c Where Id IN :lstComp]); 
         handler.OnBeforeUpdate(lstComp,lstComp,mapCompetitiveLandscape ,mapCompetitiveLandscape);
         handler.OnAfterUpdate(lstComp,lstComp,mapCompetitiveLandscape ,mapCompetitiveLandscape);
         handler.OnBeforeDelete(lstComp,mapCompetitiveLandscape);
         handler.OnAfterDelete(lstComp,mapCompetitiveLandscape);
         handler.OnUndeleted(lstComp);
         
         comp.Is_Primary_Competitor__c = true;
         // Following operation is not called by Trigger So call them for code coverage
         update comp;         
         delete comp;         
         undelete comp;
         
         System.assert(CompetitiveLandscapeTriggerHelper.NewTriggerHelper() != null);
         
         Test.stopTest();
     }
     
     static void prepareData(){
         lstComp = new List<CompetitiveLandscape__c>();
         Account acc = TestDataSetupUtility.createTestAccount('test',null,null);
         insert acc;
         comp = TestDataSetupUtility.createCompetitiveLandscape(acc.Id, true);
         lstComp.add(comp);         
         
     }

}