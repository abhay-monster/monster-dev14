@isTest
public with sharing class ExportCustomFieldsController_Test {

	static testMethod void testExportCustomFieldsController(){
		Test.startTest();
		ExportCustomFieldsController controller = new ExportCustomFieldsController();
		System.assert(controller!=null, 'Assertion Failed');
		Test.stopTest();
	}
}