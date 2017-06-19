@isTest
public class AttributeUtilityClassTest{

    static testMethod void AttributeUtilityTest(){
    
        Attribute_Value__c attributeValue;
        Attribute_Value_Group__c attributeGroup;
        Attribute_Value_Group_Member__c member;
        
       // try{
        attributeValue = new Attribute_Value__c();
        attributeValue.Attributes_Name__c = 'Test';
        attributeValue.Sequence__c = 3;
        insert attributeValue;
        
        attributeGroup = new Attribute_Value_Group__c();
        attributeGroup.Indexing_Key__c = 'Test';
        insert attributeGroup;
        
        Product2 prd = new Product2();
        prd.Name = 'testproduct';
        prd.ProductCode = 'testcode';
        insert prd;
        
        member  = new Attribute_Value_Group_Member__c ();
        member.Attribute_Value__c = attributeValue.Id;
        member.Attribute_Value_Group__c = attributeGroup.Id;
        member.Product_Code__c = prd.ProductCode;
        insert member;
        
        
        //}catch(exception e){
        
        //system.assert(false,'Errorinserting data');
        //}
        
        Set<Id> avgIdSet = new set<Id>{attributeGroup.id};
        
        Test.StartTest();
        AttributeUtilityClass.getAttribueValueList(avgIdSet);
        system.assertNotEquals(avgIdSet,null);
        Test.STopTest();
    
    }
  }