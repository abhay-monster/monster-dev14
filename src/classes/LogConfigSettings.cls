/*******************************************************************************
* @author       Andre Calimlim
* @date         5.19.2014
* @description  Class that is used to retrieve the LogConfig custom settings of 
*               the current user profile. 
*******************************************************************************/

public class LogConfigSettings{

    private static LogConfig__c theSetting = LogConfig__c.getInstance(UserInfo.getUserId());

    //private static List<RecordType> recordTypes = [SELECT Id, Name from RecordType WHERE SobjectType =: 'Log__c'];

    public static Id getDebugRecordType(){
       /* for(RecordType rt : recordTypes){
            if(rt.Name == theSetting.Debug_Record_Type__c){
                return rt.Id;
            }
        }*/
        if(Schema.SObjectType.Log__c.getRecordTypeInfosByName().get(theSetting.Debug_Record_Type__c) != null){
            return Schema.SObjectType.Log__c.getRecordTypeInfosByName().get(theSetting.Debug_Record_Type__c).getRecordTypeId();
        }

        return null;       
    }

    public static Id getExceptionRecordType(){
       /* for(RecordType rt : recordTypes){
            if(rt.Name == theSetting.Exception_Record_Type__c){
                return rt.Id;
            }
        }  */
        if(Schema.SObjectType.Log__c.getRecordTypeInfosByName().get(theSetting.Exception_Record_Type__c) != null){
            return Schema.SObjectType.Log__c.getRecordTypeInfosByName().get(theSetting.Exception_Record_Type__c).getRecordTypeId();
        }
        return null;  

    }

    public static  Boolean loggingEnabled(){
        return theSetting.Logging_Enabled__c;
    }

    public static  Boolean exceptionEnabled(){
        return theSetting.Exceptions_Enabled__c;
    }
}