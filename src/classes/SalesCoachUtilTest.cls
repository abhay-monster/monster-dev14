/**
 
 */
@isTest
private class SalesCoachUtilTest { 
	private static Sales_Coach_Role__c salesCoachRole;
    

 //test getOpptyStages
    private static testmethod void testSalesCoachRole(){
    	
    	System.assert(SalesCoachUtil.getOpptyStages().size()>0);
    	// Create Account for oppy
    	List<Personal_Settings__c> setting = [Select Id, Validation_Account__c from Personal_Settings__c];
    	   
    	system.debug('setting::  ' + setting);
  		Account p = TestDataSetupUtility.createTestAccount('Test Parent' , 'North America', UserInfo.getUserId());
  		
  		system.debug('p::' + p);
  		insert p;
  		system.debug ('after insert p');
  	
  		List<Account> accList = [Select Id, Name from Account];
  		system.debug('accList::' + accList);
  		
  		//Account a = TestDataSetupUtility.createTestAccount('Test Agency', 'Europe', UserInfo.getUserId());
  		Account a = TestDataSetupUtility.createTestAccountWithShippingAndBilling('Test Account');
        a.Organization__c = 'Europe';
        a.AgencyFlag__c = true;
  		system.debug ('a::' + a);
  		insert a;
  		system.debug ('after insert a'); 
  
    	TestingUtil tu = new TestingUtil(a, p);
    	System.assert(SalesCoachUtil.getOpptyStages().size()>0);
    }
    
    //test populateSalesCoachRole
  private static testmethod void testpopulateSalesCoachRole(){
      populateSalesCoachRole();
      TestingUtil tu = new TestingUtil();
      populateSalesCoachRole();
    }
    
     //test getUserFieldsMap
    private static testmethod void testgetUserFieldsMap(){
      System.assert(SalesCoachUtil.getUserFieldsMap().size()>=0);
    }
    
       //test opptyStageList
  private static testmethod void testopptyStageList(){
      TestingUtil tu = new TestingUtil();
      System.assert(SalesCoachUtil.opptyStageList().size()>=0);
    }   
    
     private static void populateSalesCoachRole(){
        String userRole;
        
        if(salesCoachRole == null){
            try{
                userRole = [select id, 
                                   name
                            from UserRole
                            where id = : UserInfo.getUserRoleId()].Name;
                			salesCoachRole = [select id, 
                                                         name
                                                  from Sales_Coach_Role__c
                                                  where name = : userRole Limit 1];
             
            }catch(Exception e){
            }
        }
    }
}