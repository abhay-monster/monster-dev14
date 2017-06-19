/**
 * @description Batch Service Class that ...
 * @author B. Cheek
 * @company Cloud Sherpas Inc.
 * @date 25.MAR.2013
 */
public with sharing class BatchProcessServiceTemplate {
    
    private final String CLASSNAME = '\n\n **** BatchProcessServiceTemplate.';  
        
/**
 * @description Build the query string for the GetQueryLocator
 * @author B. Cheek
 * @date 25.MAR.2013
 * @param none
 * @returns Query String
 */
    public String GetQuery(){
        
        final String METHODNAME = CLASSNAME + 'GetQuery()';
        
        StringBuilder sb = StringBuilder.NewStringBuilder();
        // build query here
        system.debug('\n\n QUERY :: ' + sb.AsString()+ '\n\n');             
        return sb.AsString();
    }   

/**
 * @description Set the QueryLocator
 * @author B. Cheek
 * @date 25.MAR.2013
 * @param Query String
 * @returns Database.Querylocator
 */
    public Database.Querylocator GetQueryLocator(String pQuery){
        
        final String METHODNAME = CLASSNAME + 'GetQueryLocator()';
        
        return Database.getQueryLocator(pQuery);
    }
    
/**
 * @description ...
 * @author B. Cheek
 * @date 25.MAR.2013
 * @param SObject list
 * @returns Nothing
 */
    public void ProcessBatch(list<SObject> scope){
        
        final String METHODNAME = CLASSNAME + 'ProcessBatch()';     
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside ') + ' with Scope Size'+ scope.size() +'\n\n');
        
        // write batch code here
    }   
    
    
/**
 * @description ...
 * @author B. Cheek
 * @date 25.MAR.2013
 * @param SObject list
 * @returns Nothing
 */
    public void FinishBatch(){
        
        final String METHODNAME = CLASSNAME + 'FinishBatch()';      
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        // write finish code here
    }         
}