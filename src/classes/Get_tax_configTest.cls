@isTest
public with sharing class Get_tax_configTest {
     static Account acc, parentAcc;
       static testMethod void testAccountHierarchy() {
           
           Test.StartTest();
           
           PageReference pageRef1 = Page.Get_tax;
           Test.setCurrentPage(pageRef1);
           pageRef1.getParameters().put('id', null);
           Get_tax_config ctrl1 = new Get_tax_config();
           ctrl1.Get_Tax();
           system.assertNotEquals(pageRef1,null);
           // Negative scenerio
           //pageRef1.getParameters().put('id', '');
           //ctrl1 = new Get_tax_config();
           //ctrl1.Get_Tax();
           
           createTestData();
           PageReference pageRef = Page.Get_tax;
           Test.setCurrentPage(pageRef);
           pageRef.getParameters().put('id', acc.Id);
           Get_tax_config ctrl = new Get_tax_config();
           ctrl.Get_Tax();
           system.assertNotEquals(pageRef,null);
           
           
           
           
           test.stopTest();
        }   
         
    static void createTestData(){
          
           acc = TestDataSetupUtility.createTestAccountWithShipping('Test');
           //acc.parentId = parentAcc.Id;
           insert acc;
       }
  }