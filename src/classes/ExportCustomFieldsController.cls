Public class ExportCustomFieldsController{
    
    Public Map<String,String> CustomFieldMap{get;set;}
    
    Public ExportCustomFieldsController(){
        Try
        {
            CustomFieldMap = New Map<String,String>();
            List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();    
            
            Schema.sObjectType sobject_type = Apttus_Config2__ProductAttributeValue__c.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            for(String Field_name:field_map.keyset()){
                string label = field_map.get(Field_name).getDescribe().getlabel(); 
                List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
                for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                    CustomFieldMap.put(a.getValue(),label);  
                }
            }
            
            
            
        }
        catch(Exception e)
        { 
            System.debug('Error'+e.getMessage()+e.getLineNumber());
        }
    }
}