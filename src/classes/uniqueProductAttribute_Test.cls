@isTest
public class uniqueProductAttribute_Test {

	static testMethod void testUniqueProductAttribute(){
		Test.startTest();
		
		List<Apttus_Config2__ProductAttributeGroupMember__c> listAttrGrpMember = new List<Apttus_Config2__ProductAttributeGroupMember__c>();
		
		Product2 product = TestDataSetupUtility.createProduct('Test Product' ,  true);
		Product2 product1 = TestDataSetupUtility.createProduct('Test Product 1' ,  true);

		Apttus_Config2__ProductAttributeGroup__c attrGroup = new Apttus_Config2__ProductAttributeGroup__c();
		insert attrGroup;
		
		Apttus_Config2__ProductAttributeGroupMember__c attrGroupMember = new Apttus_Config2__ProductAttributeGroupMember__c(Apttus_Config2__AttributeGroupId__c=attrGroup.id, Apttus_Config2__Sequence__c=5, Apttus_Config2__ProductId__c=product.Id);
		Apttus_Config2__ProductAttributeGroupMember__c attrGroupMember2 = new Apttus_Config2__ProductAttributeGroupMember__c(Apttus_Config2__AttributeGroupId__c=attrGroup.id, Apttus_Config2__Sequence__c=10, Apttus_Config2__ProductId__c=product1.Id);
		//insert attrGroupMember;
		listAttrGrpMember.add(attrGroupMember);
		listAttrGrpMember.add(attrGroupMember2);
		insert listAttrGrpMember;
		
		//attrGroupMember.P_Attribute_Group_Member_External_Id__c = 'test';
		//attrGroupMember.Apttus_Config2__FieldUpdateCriteriaIds__c = 'testing111';
		//attrGroupMember2.P_Attribute_Group_Member_External_Id__c = 'test65363';
		//attrGroupMember2.Apttus_Config2__FieldUpdateCriteriaIds__c = 'testing11136545';
		//update listAttrGrpMember;
		
		Test.stopTest();
	}
}