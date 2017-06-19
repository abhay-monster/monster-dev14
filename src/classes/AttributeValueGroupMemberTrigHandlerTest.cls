@isTest
private class AttributeValueGroupMemberTrigHandlerTest {
    static User sysAdmin;
    static Account acc;
    static Contact con;
    static Profile p;
    static {
        p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        sysAdmin =  TestDataSetupUtility.createTestUser('Test ', ' Sys Ad', p.Id);
        insert sysAdmin;
    
    }
    static testMethod void testAttributeValueGroupMemberTrigger(){
        System.runAs(sysAdmin){
            List<Attribute_Value__c> attributeValueList = new List<Attribute_Value__c>();
            List<Attribute_Value_Group__c> attributeGroupList = new List<Attribute_Value_Group__c>();
            List<Attribute_Value_Group_Member__c> memberList = new List<Attribute_Value_Group_Member__c>();
            
            Product2 prodProduct = new Product2(Name = 'Pname',productCode='Pcode1' ,isActive = true); 
            insert prodProduct;
            
            attributeValueList.add( new Attribute_Value__c(Attributes_Name__c = 'Test1', Sequence__c = 3, Attribute_Type__c = 'Product'));
            attributeValueList.add( new Attribute_Value__c(Attributes_Name__c = 'Test2', Sequence__c = 2, Attribute_Type__c = 'Product'));
            attributeValueList.add( new Attribute_Value__c(Attributes_Name__c = 'Test3', Sequence__c = 4, Attribute_Type__c = 'Proposal'));
            attributeValueList.add( new Attribute_Value__c(Attributes_Name__c = 'Test4', Sequence__c = 5, Attribute_Type__c = 'Proposal'));
            insert attributeValueList;
            
            attributeGroupList.add( new Attribute_Value_Group__c(Indexing_Key__c = 'TestG1'));
            attributeGroupList.add( new Attribute_Value_Group__c(Indexing_Key__c = 'TestG2'));
            attributeGroupList.add( new Attribute_Value_Group__c(Indexing_Key__c = 'TestG3'));
            attributeGroupList.add( new Attribute_Value_Group__c(Indexing_Key__c = 'TestG4'));
            insert attributeGroupList;
            
            // create product attribute rule definitions
            Product_Attribute_Rule_Definitions__c pardRecord = new Product_Attribute_Rule_Definitions__c();
            pardRecord.Controlling_Attribute_Value_Group__c = attributeGroupList[0].Id;
            pardRecord.Primary_Product__c = prodProduct.Id;
            insert pardRecord;
            
            memberList.add(new Attribute_Value_Group_Member__c (PARD__c = Null,Group_Record_Identifier__c = 'dDEP', Product_Code__c = prodProduct.productCode, Attribute_Value__c = attributeValueList[0].Id,Attribute_Value_Group__c = attributeGroupList[0].Id));
            //memberList.add(new Attribute_Value_Group_Member__c (Bundle__c = prodProduct.Id,PARD__c = 2,Group_Record_Identifier__c = 'qCTRL', Product_Code__c = prodProduct.productCode, Attribute_Value__c = attributeValueList[0].Id,Attribute_Value_Group__c = attributeGroupList[0].Id));
            memberList.add(new Attribute_Value_Group_Member__c (PARD__c = 2,Group_Record_Identifier__c = 'qCTRL', Product_Code__c = prodProduct.productCode, Attribute_Value__c = attributeValueList[2].Id,Attribute_Value_Group__c = attributeGroupList[2].Id));
            memberList.add(new Attribute_Value_Group_Member__c (Product_Code__c = prodProduct.productCode,Attribute_Value__c = attributeValueList[1].Id,Attribute_Value_Group__c = attributeGroupList[0].Id));
            //memberList.add(new Attribute_Value_Group_Member__c (Bundle__c = prodProduct.Id,PARD__c = 4,Group_Record_Identifier__c = 'aDEP',Product_Code__c = prodProduct.productCode,Attribute_Value__c = attributeValueList[2].Id,Attribute_Value_Group__c = attributeGroupList[1].Id));
            memberList.add(new Attribute_Value_Group_Member__c (PARD__c = 4,Group_Record_Identifier__c = 'aDEP',Product_Code__c = prodProduct.productCode,Attribute_Value__c = attributeValueList[3].Id,Attribute_Value_Group__c = attributeGroupList[3].Id));
            memberList.add(new Attribute_Value_Group_Member__c (Product_Code__c = prodProduct.productCode,Attribute_Value__c = attributeValueList[3].Id,Attribute_Value_Group__c = attributeGroupList[1].Id));
            insert memberList;
            
            AttributeValueGroupMemberTriggerHandler.RollupNamesToList(new set<Id>{memberList[0].Id, memberList[1].Id, memberList[2].Id, memberList[3].Id}); 
            AttributeValueGroupMemberTriggerHandler.sortAttributesList(attributeValueList);
            AttributeValueGroupMemberTriggerHandler.UpsertMemberParents(memberList);
        	AttributeValueGroupMemberTriggerHandler.UpsertMemberParents2(memberList);
        }
    
    }
}