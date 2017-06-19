@isTest
public class ExportHandlerController_Test {

    static testMethod void testExportHandlerController(){
        Test.startTest();
        ExportHandlerController controller = new ExportHandlerController();
        PageReference pr = controller.exportCustomFields();
        System.assert(pr!=null);
        Test.stopTest();
    }
}