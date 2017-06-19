/**
 *  Apttus Approvals Management
 *  CreditRequestApprovalEmailController
 *   
 *  @2012-2013 Apttus Inc. 
 */
public with sharing class CreditRequestApprovalEmailController {
    
    // field names
    private static final String FIELD_NAME_ID = 'Id';
    
    // state
    
    // context controller
    private Apttus_Approval.ContextApprovalEmailController context = null;
    // case sobject
    private Credit_Request__c creditRequestSO = null;
    
    /**
     * Class Constructor
     */
    public CreditRequestApprovalEmailController() {
        // create the context
        this.context = new Apttus_Approval.ContextApprovalEmailController();
        
    }
    
    /**
     * Gets the context controller
     * @return the context controller
     */
    public Apttus_Approval.ContextApprovalEmailController getContext() {
        return context;
        
    }
    
    /**
     * Gets the case sobject
     * @return the case sobject
     */
    public Credit_Request__c getCreditRequestSO() {
        
        if (creditRequestSO == null) {
            Apttus_Approval__Approval_Request__c requestSO = Context.getRequestSO();
            // make sure the object id is available. Email Template preview will not have it populated,
            // in which case we create an empty case object
            system.debug('**requestSO**' +requestSO + '**creditRequestSO **' +creditRequestSO );
            creditRequestSO = (requestSO != null && requestSO.Apttus_Approval__Object_Id__c != null 
                      ? getCreditRequestSO(requestSO.Apttus_Approval__Object_Id__c) 
                      : new Credit_Request__c());
            
        }
        
        return creditRequestSO;
        
    }
    
    /**
     * Gets the case sobject for the given case id
     * @param caseId the case id
     * @return the case sobject
     */
    @TestVisible private static Credit_Request__c getCreditRequestSO(ID creditRequestId) {
        
        // build the case query
        String qryStr = 'SELECT ';
        
        // get field names from the object 
        List<String> fieldNames = new List<String>();
        
        Integer numFields = 0;
        // add object fields
        Schema.DescribesObjectResult metadata = Credit_Request__c.getSobjectType().getDescribe();
        for (Schema.SObjectField field : metadata.fields.getMap().values()) {
            Schema.DescribeFieldResult fldMetadata = field.getDescribe();
            if (numFields > 0) {
                qryStr += ',';
                
            }
            
            // add the field
            qryStr += fldMetadata.getName();
            
            numFields++;
        
        }
        
        qryStr += ' FROM ' + Credit_Request__c.getSObjectType();
        qryStr += ' WHERE ';
        qryStr += FIELD_NAME_ID + ' = :creditRequestId';
        
        qryStr += ' LIMIT 1';
    
        // get the case sobjects
        List<Credit_Request__c> creditRequests = Database.query(qryStr);
        
        return (!creditRequests.isEmpty() ? creditRequests[0] : null);
        
    }
    
}