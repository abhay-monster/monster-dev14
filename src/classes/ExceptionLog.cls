/*
** @author : Cloud Sherpas Inc.
** @date : 06/12/2014
** @description : Writes errors to the Exception Log object
*/
public class ExceptionLog {

    public static void add(String typeOfException, String objectName, String functionName, String fullException){

        system.debug(LoggingLevel.INFO,'**** Inside ExceptionLog.add()');

        ExceptionLog__c newExceptionLog = new ExceptionLog__c();
        newExceptionLog.TypeOfException__c = typeOfException;
        newExceptionLog.ObjectName__c = objectName;
        newExceptionLog.FunctionName__c = functionName;
        newExceptionLog.Exception__c = fullException;

        system.debug(LoggingLevel.INFO, 'Exception Log :: ' + newExceptionLog);

        try{
        insert newExceptionLog;
        }catch(DMLException dmlex){
            system.debug(LoggingLevel.DEBUG, 'Exception Log :: ' + dmlex.getMessage());
        }
    }

    // ToDO add fields specific for TA exceptions - Jeff L updated to be bulkified
    public static ExceptionLog__c addTAException(String typeOfException, String objectName, Id recordId, String fullException, String queueId, String runId){
        //system.debug(LoggingLevel.INFO,'**** Inside ExceptionLog.addTAException()'); JFreese Appirio S-435483 4/11/17

        /*JFreese Appirio S-435483 4/11/17
        system.debug('Params: Type of Exception:' + typeOfException);
        system.debug('Object Name ' + objectName);
        system.debug('recordId ' + recordId);
        system.debug('full exception ' + fullException);
        system.debug('queueId ' + queueId);*/

        ExceptionLog__c newExceptionLog = new ExceptionLog__c();
        newExceptionLog.TypeOfException__c = typeOfException;
        newExceptionLog.ObjectName__c = objectName;
        newExceptionLog.Exception__c = fullException;
        newExceptionLog.Queue_ID__c = queueID;
        newExceptionLog.Record_ID__c = recordId;
        newExceptionLog.TA_Run_ID__c = runId;

        // system.debug(LoggingLevel.INFO, 'Exception Log :: ' + newExceptionLog); JFreese Appirio S-435483 4/11/17

        return newExceptionLog;

        /*try{
            insert newExceptionLog;
        }catch(DMLException dmlex){
            system.debug(LoggingLevel.DEBUG, 'Exception Log :: ' + dmlex.getMessage());
        }*/
    }

    public static void addTAExceptionBulk(List<ExceptionLog__c> exceptionList){
        if(exceptionList.size() > 0){
            try{
                insert exceptionList;
            } catch (Exception e) {
                system.debug('too bad we are here - no one can read a debug here ' + e.getMessage());
            }
        }
    }
}