public class TestingController
{
    public List<Integration_Attribute__c> ias {get;set;}


    public TestingController()
    {
        ias = 
        [
            SELECT  Id, Name, Dependent_Attribute_Only__c, Description__c, Filter_Field__c, 
                    Filter_Value__c, Integration_Type__c, Priority__c, Source_Field__c, Source_Object__c 
            FROM    Integration_Attribute__c 
            WHERE   Integration_Type__c includes ('MAPP')
            ORDER BY Name
        ];

        if(ias == null)
            ias = new List<Integration_Attribute__c>();
    } 
}