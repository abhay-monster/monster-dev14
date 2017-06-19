/**********************************************************************************
Class : TestDataEngine_AC_Test
Author : Manish Soni (manish.soni@appirio.com)
Description : Provide test coverage to TestDataEngine_AC.cls.
***********************************************************************************/

@isTest
private class TestDataEngine_AC_Test {

    static testMethod void testDataEngine() {
        
        TestDataEngine_AC testDataEngine = new TestDataEngine_AC();
        testDataEngine.selectedObject = 'User';
        testDataEngine.isCreateParent = true;
        testDataEngine.createTestData();
        
        System.assert(testDataEngine.testData != null);
        System.assert(testDataEngine.requiredFields != null);
    }
}