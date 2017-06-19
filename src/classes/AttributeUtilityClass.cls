public class AttributeUtilityClass {

    public static List<Attribute_Value__c> getAttribueValueList(Set<Id> avgIdSet){
       List<Attribute_Value__c> values = new List<Attribute_Value__c>();
       
       values = [SELECT Id, Attribute_Type__c, Attributes_Name__c, Attribute_Values__c
                    FROM Attribute_Value__c WHERE Id IN (SELECT Attribute_Value__c 
                                                            FROM Attribute_Value_Group_Member__c WHERE Attribute_Value_Group__c IN:avgIdSet)];
       return values; 
    }
}