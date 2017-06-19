/**********************************************************************************
Class : TestDataEngine_AC
Author : Manish Soni (manish.soni@appirio.com)
Description : Create test data for any selected object and parent object as well.

***********************************************************************************/

public without sharing class TestDataEngine_AC {
	
	public List<SelectOption> sfdcObjects {get;set;}
	public String selectedObject {get;set;}
	public String testData {get;set;}
	public Boolean isCreateParent {get;set;}
	public String requiredFields {get;set;} 
	
	private Map<String, Schema.SObjectType> globalDescribe;
	
	
	public TestDataEngine_AC(){
		sfdcObjects = getAllSFDCObjects();
	}
	
	// Method for get the select option list for all SFDC object exists in the org.
  	public List<SelectOption> getAllSFDCObjects(){
    
	    // Creating list of select option
	    List<SelectOption> options = new List<SelectOption>();
	    // Creating list for store the object labels
	    List<string> objectLabels = new List<string>();
	    // Creating map for objects, here we are using label as key and object name as a value
	    Map<string,string> mapObjects = new Map<string,string>();
	    // Getting objects list by the describe call
	    globalDescribe = Schema.getGlobalDescribe();
	    for(Schema.SObjectType f : globalDescribe.Values()){
	        objectLabels.add(f.getDescribe().getLabel());
	        mapObjects.put(f.getDescribe().getLabel(),f.getDescribe().getName());
	    }
	    objectLabels.sort(); // sort to make list alphabetical
	    options.add(new selectoption('--None--', '--None--'));
	    for(string objLabel:objectLabels){
	        options.add(new selectoption(mapObjects.get(objLabel), objLabel));
	    }
	    return options;
  	}
  
  	public void createTestData(){
  		string result = processData(selectedObject);
  		
  		testData = result.split(':~:')[0];
  		requiredFields = result.split(':~:')[1];
  		
  		
  	}
  
  	public String processData(String objectName){
	  	String parentString = '';
	  	String objectLabel = globalDescribe.get(objectName).getDescribe().getLabel();
	  	String dataString = objectName + ' test_' + objectLabel.replaceAll(' ',''); 
	  	dataString += ' = new ' + objectName;
	  	dataString += ' ( </br>';
	  	
	  	String required_Fields = '<b>' + objectLabel + ' ( ' + objectName + ' )</b></br>' ;
	  	
	  	Map<String,Schema.SObjectField> mapFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().Fields.getMap();
	  	for(Schema.SObjectField field : mapFieldMap.values()){
	      Schema.DescribeFieldResult fieldResult = field.getDescribe();
	      if((!fieldResult.isNillable() && fieldResult.isCreateable() && !fieldResult.isDefaultedOnCreate()) || (fieldResult.isNameField() && !fieldResult.isAutoNumber())){
	        // If account is person account then we need to exclude FirstName and LastName fields.
	        if(objectName.equalsIgnoreCase('Account') && mapFieldMap.containsKey('IsPersonAccount')){
	        	if(fieldResult.getName().equalsIgnoreCase('FirstName') || fieldResult.getName().equalsIgnoreCase('LastName')){
	        		continue;
	        	}
	        }
	        else if(objectName.equalsIgnoreCase('User') && !fieldResult.isCustom() && ( fieldResult.getName().startsWith('UserPreferences') || fieldResult.getName().startsWith('UserPermissions') )){
	        	continue;
	        }
	        
	        dataString += '&nbsp;&nbsp;&nbsp;&nbsp;';
	        dataString += fieldResult.getName() + ' = ' ;
	        
	        required_Fields += '&nbsp;&nbsp;&nbsp;&nbsp;';
	        required_Fields += fieldResult.getLabel() + ' ( ' + fieldResult.getName() + ' ) </br>' ;
	        
	        
	        if(fieldResult.getType() == Schema.DisplayType.Boolean){
	        	dataString += 'true,</br>';
	        }
	        else if(fieldResult.getType() == Schema.DisplayType.Currency || fieldResult.getType() == Schema.DisplayType.Double
	        	 || fieldResult.getType() == Schema.DisplayType.Integer || fieldResult.getType() == Schema.DisplayType.Percent){
	        	dataString += '1.00,</br>';
	        }
	        else if(fieldResult.getType() == Schema.DisplayType.Date){
	        	dataString +=  'Date.newinstance(' + String.valueof(Date.today().year()) + ',' + String.valueof(Date.today().month()) + ',' + String.valueof(Date.today().day()) + '),</br>';
	        }
	        else if(fieldResult.getType() == Schema.DisplayType.DateTime){
	        	dataString +=  'DateTime.newinstance(' + String.valueof(Date.today().year()) + ',' + String.valueof(Date.today().month()) + ',' + String.valueof(Date.today().day()) + '),</br>';
	        }
	        else if(fieldResult.getType() == Schema.DisplayType.Email){
	        	dataString += '\'testEmail@test.com\',</br>';
	        }
	        else if(fieldResult.getType() == Schema.DisplayType.URL){
	        	dataString += '\'http://www.testurl.com\',</br>';
	        }
	        else if(fieldResult.getType() == Schema.DisplayType.Reference){
	        	dataString +=  'test_' + fieldResult.getReferenceTo()[0].getDescribe().getLabel().replaceAll(' ','') + '.Id,</br>';
	        	if(isCreateParent == true){
	        		parentString = processData(fieldResult.getReferenceTo()[0].getDescribe().getName());
	        	}
	        }
	        else{
	        	dataString += (objectName.equalsIgnoreCase('User') && fieldResult.getName().equalsIgnoreCase('Username')) ? '\'testuser@test.com\',</br>' : '\'test value\',</br>';
	        }
	      }
	    }
	    
	    dataString = dataString.subString(0,dataString.length()-6);
	    dataString += '</br>);</br></br>';
	    required_Fields += '</br></br>';
	    if(String.isNotBlank(parentString)){
	    	dataString = parentString.split(':~:')[0] + dataString; 
	    	required_Fields = parentString.split(':~:')[1] + required_Fields;
	    }
	   
	    return dataString + ':~:' + required_Fields;
  	}
}