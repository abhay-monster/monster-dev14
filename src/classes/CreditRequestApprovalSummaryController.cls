/**
 *  Apttus Approvals Management
 *  CreditRequestApprovalSummaryController
 *   
 *  @2012-2013 Apttus Inc. 
 */
public with sharing class CreditRequestApprovalSummaryController {
  
  // field names
  private static final String FIELD_NAME_ID = 'Id';
  
  // state
  
  // case object
  private Credit_Request__c creditRequestSO = null;
  
  /**
   * Class Constructor specifying initial values
   * @param stdController the standard controller
   */
    public CreditRequestApprovalSummaryController(ApexPages.StandardController stdController) {
      
      // get the approval rule sobject
    Apttus_Approval__Approval_Request__c requestSO = (Apttus_Approval__Approval_Request__c) stdController.getRecord();
    
    // get the case sobject
    this.creditRequestSO = getCreditRequestSO(requestSO.Apttus_Approval__Object_Id__c);
    
    }
    
    /**
   * Gets the case sobject
   * @return the case sobject
   */
  public Credit_Request__c getCreditRequestSO() {
    return creditRequestSO;
    
  }
  
  /**
   * Gets the case sobject for the given case id
   * @param caseId the case id
   * @return the case sobject
   */
  private static Credit_Request__c getCreditRequestSO(ID creditRequestId) {
    
    // build the opportunity query
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