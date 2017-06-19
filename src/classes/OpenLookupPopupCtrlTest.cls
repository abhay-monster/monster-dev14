/*****************************************************************************
 * Name             : OpenLookupPopupCtrlTest
 * Created By       : Vivek Ojha(Appirio)
 * Created Date     : 03/09/2015
 * Purpose          : Test class for OpenLookupPopupCtrl 
 * Note             : 
*****************************************************************************/
@isTest(seeAllData=true)
private class OpenLookupPopupCtrlTest {
	 static testMethod void testLookUpPopUp() {
		
		Test.startTest();
		User usr = TestDataSetupUtility.createTestUser('test', 'test_Last',UserInfo.getProfileId());
	    insert usr;
	    PageReference pageRef = Page.OpenLookupPopup;
        Test.setCurrentPage(pageRef);
         
     	// Add parameters to page URL
     	ApexPages.currentPage().getParameters().put('Object', 'User');
        ApexPages.currentPage().getParameters().put('fieldName', 'Name');
        ApexPages.currentPage().getParameters().put('searchText', 'test');
        ApexPages.currentPage().getParameters().put('fieldSetName', 'User_Search_Results');
        
        OpenLookupPopupCtrl popupcntrl  = new OpenLookupPopupCtrl();
        
        Test.stopTest();
    }
}