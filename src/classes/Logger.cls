/******************************************************************************
* @author         Andre Calimlim
* @date           12.4.2014
* @description    This class is part of the Logging Framework that handles the necessary 
*     Logging methods to store the debug and exception information on the Log 
*     custom object in Salesforce. 
*/
public class Logger{ 

/******************************************************************************
* @author         Andre Calimlim
* @date           12.4.2014
* @return         StackTrace Wrapper class 
******************************************************************************/

public class StackTrace{
        public integer level{get; private set;}
        private string function;
        private string objectName;        

        public string getEntry(){
            return (objectName + ' : ' + function);
        }

        public StackTrace(integer level, string function, string objectName){
            this.level = level;
            this.function = function;
            this.objectName = objectName;
        }

    }

    //This public class should be used for creating excpetions form logical faults in the application
    public class CustomException extends Exception{}

    //Initialize static variables
    private static integer currentLevel = 0;
    private static integer sequence = 0;
    private static boolean inPageConstructor = false;
    private static List<StackTrace> stack = new List<StackTrace>();
    private static List<Log__c> debugList = new List<Log__c>();
    private static List<Log__c> exceptionList = new List<Log__c>();
    private static Id idDebugRT = LogConfigSettings.getDebugRecordType();
    private static Id idExceptionRT = LogConfigSettings.getExceptionRecordType();
    private static boolean debugLogEnabled = LogConfigSettings.loggingEnabled();
    private static boolean exceptionLogEnabled = LogConfigSettings.exceptionEnabled();

    //Initialize constant variables

    public static final string STACKSTR = ' stack: ';

    //method that will be in the Constructor if it will be used in a page

    public static void setInConstuctor(){
        inPageConstructor = true;
    }

    /******************************************************************************
    * @author         Andre Calimlim
    * @date           12.4.2014
    * @param          functionName-String denoting the name of the method from which 
                      this method was called
    * @param          objectName-String denoting the name of the class from which 
                      the method was called
    * @return         null
    * @description    
    * This method should be called when entering every method in a class. The method 
    * will initiate a stacktrace which will have the level of debug info along with 
    * the function name and object name
    ******************************************************************************/
    public static void push(string functionName, string objectName){        
            stack.add(new StackTrace(currentLevel, functionName, objectName));
            currentLevel++;       
    }

        

    public static void pop(){
        if(currentLevel > 0){
            currentLevel--;
            if(stack.size() > 0){
                stack.remove(stack.size() -1);
            }
        }        

        if(currentLevel==0){
            String debugListString = JSON.serialize(debugList);
            String exptListString = JSON.serialize(exceptionList);
            writeLogsToDatabase(exptListString, debugListString);
            debugList = new List<Log__c>();
            exceptionList = new List<Log__c>(); 
        }  

    }   

    

    /******************************************************************************
    * @author         Andre Calimlim
    * @date           12.4.2014
    * @param          debug string is passed to add data to Message
    * @return         null
    * @description    
    * This method is called by methods which needs to capture a debug statment into 
    * Salesforce. The string that needs to be displayed in the debug log is passed to 
    * this method and is added to the list of debug logs that will be inserted into 
    * Salesforce
    ******************************************************************************/

    public static void debug(string debugString){   

        Log__c log = new Log__c(
            StackTrace__c = getStackTrace(),
            Limits__c = getLimits(),
            Message__c = debugString,
            RecordTypeId = idDebugRT,
            Sequence__c = sequence);
        debugList.add(log);

        sequence++;
    }

    /******************************************************************************
    * @author         Andre Calimlim
    * @date           12.4.2014
    * @param          string
    * @return         null
    * @description    
    * This method takes a string exception parameter and then passes it to the standard
    * debug excpeption method after translating the exception to an exception type.
    ******************************************************************************/  

    public static void debugException(string exStr){
        CustomException ex = new CustomException(exStr);
        debugException(ex, null);
    }

	/******************************************************************************
    * @author         Andre Calimlim
    * @date           12.10.2014
    * @param          string
    * @return         null
    * @description    
    * This method takes a string exception parameter and Error Record Id and then passes it to the standard
    * debug excpeption method after translating the exception to an exception type.
    ******************************************************************************/  

    public static void debugException(string exStr, Id recId){
        CustomException ex = new CustomException(exStr);
        debugException(ex, recId);
    }

    /******************************************************************************
    * @author         Andre Calimlim 
    * @date           12.4.2014
    * @param          exception that will be logged
    * @return         null 
    * @description    
    * Similar to the debug method, this method is called by methods which needs to 
    * capture a exception statment into Salesforce. The string that needs to be 
    * displayed in the debug log is passed to this method and is added to the list of 
    * exception logs that will be inserted into Salesforce
    ******************************************************************************/

    public static void debugException(Exception ex, Id recId){

        string exceptionInfo = ex.getMessage() + STACKSTR 

                               + ex.getStackTraceString();

        Log__c log = new Log__c(
            StackTrace__c = getStackTrace(),
            Limits__c = getLimits(),
            Message__c = exceptionInfo,
            recordTypeId = idExceptionRT,
            ExceptionLine__c = ex.getLineNumber(),
            ExceptionType__c = ex.getTypeName(),
            Sequence__c = sequence,
            Error_Record_Id__c = recId);
            
        exceptionList.add(log);
        sequence++;
    }

    
    /******************************************************************************
    * @author         Andre Calimlim
    * @date           12.4.2014
    * @param          exptListString - list string which contains the exception data
    * @param          debugListString - list string which contains the debug data
    * @return         null
    * @description    
    * The method will insert the Log record with debug info and exception info (if necessary) 
    * depending on the custom setting of the current user profile. 
    ******************************************************************************/

    private static void writeLogsToDatabase(string exptListString, 
                                            string debugListString){
        List<Log__c> debugListParsed = (List<Log__c>)
        JSON.deserialize(debugListString,  List<Log__c>.class);
        List<Log__c> exceptListParsed = (List<Log__c>)
        JSON.deserialize(exptListString,  List<Log__c>.class);

        //Cannot make DML calls in a constructor of a visualforce page so if statement to prevent this from happening
        if(!inPageConstructor){
             //if debug custom setting is on  
            if(debugLogEnabled){
                insert debugListParsed;
            }

            //if exception custom setting is on
            if(exceptionLogEnabled){
                insert exceptListParsed;
            }
        } 

    }

    /******************************************************************************
    * @author         Andre Calimlim
    * @date           12.4.2014
    * @return         returns the stacktrace string that will contain the stack 
    *                 trace entries along with the trace level
    ******************************************************************************/  

    private static string getStackTrace(){

        string retVal ='';

        if (stack != null && stack.size() >0){
            String spaces='                                                                ';       
            for (StackTrace se : stack)   {
                Integer endIndex = 3 * se.level;
                if (endIndex >= spaces.length())
                    endIndex = spaces.length()-1;
                retVal += spaces.substring(0,endIndex)+se.getEntry()+'\n';
            }
        }

        return retVal;

    }

    /******************************************************************************
    * @author         Andre Calimlim
    * @date           12.4.2014
    * @param          null
    * @return         limit string - string that will contains the actual values of 
    *                 the limits reached by the execution against the governor limits 
    *                 set by Salesforce.
    * @description    
    * This methods uses the Limit() method in Salesforce to call all the limits 
    * reached in the current execution context againsts the governor limits set by 
    * Salesforce. 
    ******************************************************************************/  

    private static string getLimits(){        
        string limitstring = 'Script Limits: '+ Limits.getScriptStatements() + '/' +
            Limits.getLimitScriptStatements() +'\n' +
            'Query Limits: '+ Limits.getQueries() + '/' + Limits.getLimitQueries() +'\n' +
            'DML Rows Limits: '+Limits.getDMLRows()+'/' + Limits.getLimitDMLRows()+'\n' +
            'Heap Size Limits: '+Limits.getHeapSize()+'/' +Limits.getLimitHeapSize()+'\n' +
            'Query Return Limits: '+Limits.getQueryRows()+'/' + Limits.getLimitQueryRows()+'\n' +
            'Script Limits: '+Limits.getScriptStatements()+'/' + Limits.getLimitScriptStatements()+'\n' +
            'Aggregate Queries: '+Limits.getAggregateQueries()+'/' + Limits.getLimitAggregateQueries() +
            'Callouts: '+Limits.getCallouts()+'/' +Limits.getLimitCallouts() +
            'Child Relationship Describes: ' +Limits.getChildRelationshipsDescribes()+'/' +Limits.getLimitChildRelationshipsDescribes() +
            'CPU Time: '+Limits.getCpuTime()+'/' +Limits.getLimitCpuTime() +
            'DML Statements: '+Limits.getDMLStatements()+'/' +Limits.getLimitDMLStatements() +
            'Email Invocations: '+Limits.getEmailInvocations()+'/' +Limits.getLimitEmailInvocations() +
            'Fields Describes: '+Limits.getFieldsDescribes()+'/' +Limits.getLimitFieldsDescribes() +
            'Field Set Describes: '+Limits.getFieldSetsDescribes() +'/'+Limits.getFieldSetsDescribes() +
            'Future Calls: '+Limits.getFutureCalls()+'/' +Limits.getLimitFutureCalls() +
            'Picklist Describes: '+Limits.getPicklistDescribes() +'/'+Limits.getLimitPicklistDescribes() +
            'Query Locator Rows: '+Limits.getQueryLocatorRows() +'/'+Limits.getLimitQueryLocatorRows() +
            'Record Type Describes: ' +Limits.getRecordTypesDescribes()+'/' +Limits.getLimitRecordTypesDescribes();

        return limitstring;

    }
}