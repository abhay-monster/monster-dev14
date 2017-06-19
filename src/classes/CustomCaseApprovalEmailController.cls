/**
 *  Apttus Approvals Management
 *  CustomCaseApprovalEmailController
 *   
 *  @2012-2013 Apttus Inc. 
 */
public with sharing class CustomCaseApprovalEmailController {
    
    // field names
    private static final String FIELD_NAME_ID = 'Id';
    
    // state
    
    // context controller
    private Apttus_Approval.ContextApprovalEmailController context = null;
    // case sobject
    private Case caseSO = null;
    
    /**
     * Class Constructor
     */
    public CustomCaseApprovalEmailController() {
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
    public Case getCaseSO() {
        
        if (caseSO == null) {
            Apttus_Approval__Approval_Request__c requestSO = Context.getRequestSO();
            // make sure the object id is available. Email Template preview will not have it populated,
            // in which case we create an empty case object
            caseSO = (requestSO.Apttus_Approval__Object_Id__c != null 
                      ? getCaseSO(requestSO.Apttus_Approval__Object_Id__c) 
                      : new Case( SystemGenerated__c = True));
            
        }
        
        return caseSO;
        
    }
    
    /**
     * Gets the case sobject for the given case id
     * @param caseId the case id
     * @return the case sobject
     */
    private static Case getCaseSO(ID caseId) {
        
        // build the case query
        String qryStr = 'SELECT ';
        
        // get field names from the object 
        List<String> fieldNames = new List<String>();
        
        Integer numFields = 0;
        // add object fields
        Schema.DescribesObjectResult metadata = Case.getSobjectType().getDescribe();
        for (Schema.SObjectField field : metadata.fields.getMap().values()) {
            Schema.DescribeFieldResult fldMetadata = field.getDescribe();
            if (numFields > 0) {
                qryStr += ',';
                
            }
            
            // add the field
            qryStr += fldMetadata.getName();
            
            numFields++;
        
        }
        
        qryStr += ' FROM ' + Case.getSObjectType();
        qryStr += ' WHERE ';
        qryStr += FIELD_NAME_ID + ' = :caseId';
        
        qryStr += ' LIMIT 1';
    
        // get the case sobjects
        List<Case> cases = Database.query(qryStr);
        
        return (!cases.isEmpty() ? cases[0] : null);
        
    }
    
}