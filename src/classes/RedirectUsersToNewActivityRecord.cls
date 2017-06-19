//------------------------------------------------------------------------------------------------------------
//  Name: RedirectUsersToNewActivityRecord
//  Date: 5/Jun/2015
//  Author: Gaurav (Appirio Ind.)
//  Purpose: Used in Visualforce page RedirectUsersToNewActivityRecord to redirect users to Pages
//------------------------------------------------------------------------------------------------------------

public class RedirectUsersToNewActivityRecord{
    public List<Task> obj{get;set;}
    public string url{get;set;}
    private string accountId;
    private string opportunityId;
    private string contactId;
    private string proposalId;
    private string whatId;
    private string whoId;
    private string activityType;
    RecordTypeIDs__c recordTypeIds= RecordTypeIDs__c.getInstance(userinfo.getProfileId());
    
    // Constructor
    
    public redirectUsersToNewActivityRecord(ApexPages.StandardController controller){
        accountId = ApexPages.currentPage().getParameters().get('Account_Id');
        opportunityId = ApexPages.currentPage().getParameters().get('Opportunity_Id');
        contactId = ApexPages.currentPage().getParameters().get('Contact_Id');
        proposalId = ApexPages.currentPage().getParameters().get('Proposal_Id');
        activityType = ApexPages.currentPage().getParameters().get('Activity_type');
       
    }
    
     /**
     * Method to return the page url that the user will going to be redirected to 
     * @return PageReference (Return url of the New Task/Event Page)
     */ 
         
    public PageReference redirectUser(){
    
        Profile_Permissions__c activityRedirect= Profile_Permissions__c.getInstance(userinfo.getProfileId());
       
        if(proposalId != ''){
               whatId = proposalId ;
         } else If(opportunityId != ''){
             whatId = opportunityId ;
         } else If(contactId  != ''){
             whoId= contactId  ;
         } else{
            whatId = accountId ; 
         }
         
         if(activityType == 'Task'){
             if(activityRedirect.Task_Redirect__c == true){   
                if(whatId!= null)
                    url = '/00T/e?what_id=' + whatId + '&retURL=' + whatId + '&RecordType='+recordTypeIds.Task_Sales__c+ '&ent=Task';
                else
                    url = '/00T/e?who_id=' + whoId + '&retURL=' + whoId + '&RecordType='+recordTypeIds.Task_Sales__c+ '&ent=Task';
              }
              else{
                if(whatId!= null)
                    
                    url = '/setup/ui/recordtypeselect.jsp?ent=Task&retURL=%2F'+whatId+'&save_new_url=%2F00T%2Fe%3Fwhat_id%3D'+whatId+'%26retURL%3D%252F'+whatId;
                else
                    url = '/setup/ui/recordtypeselect.jsp?ent=Task&retURL=%2F'+whoId+'&save_new_url=%2F00T%2Fe%3Fwho_id%3D'+whoId+'%26retURL%3D%252F'+whoId;                    
              }
           }else if(activityType == 'Event'){
             if(activityRedirect.Event_Redirect__c== true){   
                if(whatId!= null)
                    url = '/00U/e?what_id=' + whatId + '&retURL=' + whatId + '&RecordType='+recordTypeIds.Event_SalesEvent__c+ '&ent=Event';
                else
                    url = '/00U/e?who_id=' + whoId + '&retURL=' + whoId + '&RecordType='+ recordTypeIds.Event_SalesEvent__c+'&ent=Event';
              }
              else{
                if(whatId!= null)
                    url = '/setup/ui/recordtypeselect.jsp?ent=Event&retURL=%2F'+whatId+'&save_new_url=%2F00U%2Fe%3Fwhat_id%3D'+whatId+'%26retURL%3D%252F'+whatId;
                else                 
                      url = '/setup/ui/recordtypeselect.jsp?ent=Event&retURL=%2F'+whoId+'&save_new_url=%2F00U%2Fe%3Fwho_id%3D'+whoId+'%26retURL%3D%252F'+whoId;
              }          
          }
          // Log a Call logic
          else {          
              if(activityRedirect.Task_Redirect__c == true){   
                if(whatId!= null)
                    url = '/00T/e?title=Call&what_id=' + whatId + '&followup=1&tsk5=Call&retURL=' + whatId + '&RecordType='+recordTypeIds.Task_Sales__c+ '&ent=Task';
                else
                    url = '/00T/e?title=Call&who_id=' + whoId + '&followup=1&tsk5=Call&retURL=' + whoId + '&RecordType='+recordTypeIds.Task_Sales__c+ '&ent=Task';
              }
              else{
                if(whatId!= null)
                    
                    url = '/setup/ui/recordtypeselect.jsp?ent=Task&retURL=%2F'+whatId+'&save_new_url=%2F00T%2Fe%3Ftitle%3DCall%26what_id%3D'+whatId+'%26followup%3D1%26tsk5%3DCall%26retURL%3D%252F'+whatId;
                else
                    url = '/setup/ui/recordtypeselect.jsp?ent=Task&retURL=%2F'+whoId+'&save_new_url=%2F00T%2Fe%3Ftitle%3DCall%26who_id%3D'+whoId+'%26followup%3D1%26tsk5%3DCall%26retURL%3D%252F'+whoId;                    
              } 
          }
            
        PageReference p = new PageReference(url);
          return p;
        }
}