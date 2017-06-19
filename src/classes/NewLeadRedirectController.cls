public class NewLeadRedirectController {

    
    public NewLeadRedirectController(ApexPages.StandardController controller){
        
    }
    
     /**
     * Method to return the page url that the user will going to be redirected to 
     * @return PageReference (Return url of the New Task/Event Page)
     */ 
         
    public PageReference redirectUser(){  
      
      string Url = null;
      Profile_Permissions__c recordTypeRedirect = Profile_Permissions__c.getInstance(userinfo.getProfileId());
      string recordType = recordTypeRedirect.Redirect_Lead_to_RecordType__c;
      User user = [Select Id, Name, UserRole.Name from User where Id = :Userinfo.getUserId() Limit 1];
      
      if(recordType == null && user.UserRole.Name != null) {
         for(Role_Settings__c role : Role_Settings__c.getAll().values()){
             if(user.UserRole.Name.contains(role.Name)){
                recordType = role.Redirect_RecordType__c;
             }
         }
      }
      
      
      Url = '/setup/ui/recordtypeselect.jsp?ent=Lead&retURL=%2F00Q%2Fo&save_new_url=%2F00Q%2Fe%3FretURL%3D%252F00Q%252Fo&nooverride=1';
     
      if(Schema.SObjectType.Lead.getRecordTypeInfosByName().containsKey(recordType)) {
          Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(recordType).getRecordTypeId();          
          Url = '/00Q/e?retURL=%2F00Q%2Fo&RecordType='+LeadRecordTypeId+'&ent=Lead&nooverride=1';
          return new ApexPages.PageReference(Url).SetRedirect(true);
      }     
      
      return new ApexPages.PageReference(Url).SetRedirect(true);
    
    }
    
  
}