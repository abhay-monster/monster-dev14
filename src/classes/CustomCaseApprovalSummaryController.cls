/**
 *	Apttus Approvals Management
 *	CustomCaseApprovalSummaryController
 *	 
 *	@2012-2013 Apttus Inc. 
 */
public with sharing class CustomCaseApprovalSummaryController {
	
	// field names
	private static final String FIELD_NAME_ID = 'Id';
	
	// state
	
	// case object
	private Case caseSO = null;
	
	/**
	 * Class Constructor specifying initial values
	 * @param stdController the standard controller
	 */
    public CustomCaseApprovalSummaryController(ApexPages.StandardController stdController) {
    	
    	// get the approval rule sobject
		Apttus_Approval__Approval_Request__c requestSO = (Apttus_Approval__Approval_Request__c) stdController.getRecord();
		
		// get the case sobject
		this.caseSO = getCaseSO(requestSO.Apttus_Approval__Object_Id__c);
		
    }
    
    /**
	 * Gets the case sobject
	 * @return the case sobject
	 */
	public Case getCaseSO() {
		return caseSO;
		
	}
	
	/**
	 * Gets the case sobject for the given case id
	 * @param caseId the case id
	 * @return the case sobject
	 */
	private static Case getCaseSO(ID caseId) {
		
		// build the opportunity query
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