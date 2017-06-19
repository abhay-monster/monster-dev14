/*****************************************************************************
 * Name             : CustomLookupCtrlTest
 * Created By       : Vivek Ojha(Appirio)
 * Created Date     : 03/09/2015
 * Purpose          : Test class for CustomLookupCtrl 
 * Note             : 
*****************************************************************************/
@isTest
private class CustomLookupCtrlTest {

    static testMethod void testCustomLookUp() {
        
        Test.startTest();
        Account acc = TestDataSetupUtility.createTestAccountWithShipping('Test-Acc-1');
 		insert acc;
	    
        CustomLookupCtrl CLC = new CustomLookupCtrl();
        CLC.selectedId = acc.ID;
        CLC.objName = 'Account';
        CLC.fieldName ='Name';
        CLC.getSelectedRecord();        
        
        Test.stopTest();
    }
    
   
}