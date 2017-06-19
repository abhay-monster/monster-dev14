@isTest
Private Class QueriableMetaDataLookupController_Test{

    static testmethod void testQueriableMetaDataLookupController(){
        
        Test.startTest();
        QueriableMetaDataLookupController ctrl = new QueriableMetaDataLookupController();
        system.assert(ctrl.results.isEmpty());
        ctrl.queryStr = 'QueriableMetaDataLookupController';
        ctrl.getResults();  
        system.assert(!ctrl.results.isEmpty());  
        ctrl.updateResults();       
        Test.stopTest();
    }
   

}