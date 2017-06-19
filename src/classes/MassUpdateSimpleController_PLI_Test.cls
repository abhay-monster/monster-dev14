/***************************************************************************************************************************
 * Class Name   : MassUpdateSimpleController_PLI_Test
 * Created By   : Rohit B. (Appirio)
 * Class Purpose: Test class of MassUpdateSimpleController_PLI class 
 * Created Date : July 20, 2015
 * 
 * Class Date Modified          Modified By                     Description of the update
 * [Date]                       [Person Name]                   [Short description of modification]
****************************************************************************************************************************/
@isTest
private class MassUpdateSimpleController_PLI_Test {
	
	@isTest 
	static void test_method() {
		Apttus_Proposal__Proposal_Line_Item__c propLI = new Apttus_Proposal__Proposal_Line_Item__c();
		List<Apttus_Proposal__Proposal_Line_Item__c> lstPropLineItem = [SELECT Id, Apttus_QPConfig__LineStatus__c, Apttus_QPConfig__EndDate__c, 
                                                                        Quantity1__c, StateProvinceTaxRate__c, Is_Trail_Product__c, 
                                                                        Hiring_URL__c, Apttus_QPConfig__PricingDate__c
																		FROM Apttus_Proposal__Proposal_Line_Item__c];

        User usrTest = [Select Id from User where Profile.Name =: 'System Administrator' and isActive = true limit 1];
        system.runAs(usrTest) {
            Test.startTest();
        		PageReference pageref = Page.MassUpdateCustomObject_prposal_line_item;
                Test.setCurrentPage(pageref);

        	    ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(lstPropLineItem);
            	setCtr.setSelected(new Apttus_Proposal__Proposal_Line_Item__c[]{propLI});
                MassUpdateSimpleController_PLI ctrl = new MassUpdateSimpleController_PLI(setCtr);

                ctrl.proplineitem = lstPropLineItem;

                List<SelectOption> opts = ctrl.getFieldTypeOptions();
                List<SObject> lstsObj = ctrl.objsToUpdate;
                ctrl.fieldName = 'Apttus_QPConfig__LineStatus__c';
                
                System.assert(ctrl.step1()!=null);
                System.assert(ctrl.step2()!=null);
                System.assert(ctrl.step3()!=null);
                System.assert(ctrl.step4()!=null);
                System.assert(ctrl.step5()!=null);
                System.assert(ctrl.getStep()!=null);
                System.assert(ctrl.getsType()==null);
                System.assert(ctrl.getNow(true)!=null);
                System.assert(ctrl.getNow(false)!=null);
                System.assert(ctrl.cancel()!=null);
                System.assert(ctrl.getPicklistValues()!=null);
                System.assert(ctrl.getFieldInfoToDisplay()!=null);

                ctrl.fieldName = 'Apttus_QPConfig__EndDate__c';
                System.assert(ctrl.getFieldInfoToDisplay()!=null);
                System.assert(ctrl.step4()!=null);

                ctrl.fieldName = 'Quantity1__c';
                System.assert(ctrl.getFieldInfoToDisplay()!=null);
                System.assert(ctrl.step4()!=null);

                ctrl.fieldName = 'StateProvinceTaxRate__c';
                System.assert(ctrl.getFieldInfoToDisplay()!=null);
                System.assert(ctrl.step4()!=null);

                ctrl.fieldName = 'Is_Trail_Product__c';
                System.assert(ctrl.getFieldInfoToDisplay()!=null);
                System.assert(ctrl.step4()!=null);

                ctrl.fieldName = 'Hiring_URL__c';
                System.assert(ctrl.getFieldInfoToDisplay()!=null);
                System.assert(ctrl.step4()!=null);

                ctrl.fieldName = 'Apttus_QPConfig__PricingDate__c';
                System.assert(ctrl.getFieldInfoToDisplay()!=null);
                System.assert(ctrl.step4()!=null);
            Test.stopTest();
        } // END system.runAs(usrTest) {
	} // END static void test_method() {

	@testSetup
	static void setupData() {
		Account acc = TestDataSetupUtility.createTestAccountWithShipping('Test Account');
        insert acc;
        
        Opportunity opp = TestDataSetupUtility.createTestOpportunity('Test Opp 1', acc.Id);
        insert opp;
        
        Apttus_Proposal__Proposal__c prop = TestDataSetupUtility.createApttusProposal(opp);
        prop.Apttus_Proposal__Account__c = acc.Id;
        insert prop;
        
        List<Apttus_Proposal__Proposal_Line_Item__c> lstPropLineItem = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        Apttus_Proposal__Proposal_Line_Item__c propLineItem1 = TestDataSetupUtility.createProposalLineItem(prop.Id);
        propLineItem1.Apttus_QPConfig__LineStatus__c = 'Renewed';
        propLineItem1.Apttus_QPConfig__EndDate__c = System.now().date();
        propLineItem1.Apttus_QPConfig__PricingDate__c = System.now();
        lstPropLineItem.add(propLineItem1);
        insert lstPropLineItem;
	} // END static void setupData() {
} // END Class MassUpdateSimpleController_PLI_Test