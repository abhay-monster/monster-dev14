/*
** @author : Phuong Tran
** @date : 10/28/2015
** @description : Handler called from  PerformanceVFPDetailTrigger to monitor system performance
*/

public class PerfVFPDetailTriggerHandler {
    
        public void OnBeforeInsert(Performance_VFP_Detail__c[] vfPages){
            System.debug('*****Entering PerfVFPDetailTriggerHandler.OnBeforeInsert');
            // List of new master records to create
            List<Performance_Prod_User_ID_Mapping__c> prodUserList = new List<Performance_Prod_User_ID_Mapping__c>();
            List<Performance_VFP__c> vfpList = new List<Performance_VFP__c>();
            // Link Visual Force Pages to Master VFP
            List<Performance_VFP__c> visualForcePages = [select id, Name
                                                         from Performance_VFP__c];
            Map<String, String> vfpMap = new Map<String, String>();
            For(Performance_VFP__c v : visualForcePages){
            	vfpMap.put (v.Name, v.id);
            }
            // Map user id to nice user name
            List<Performance_Prod_User_ID_Mapping__c> users = [select UserId__c, User_Name__c 
                                           from Performance_Prod_User_ID_Mapping__c];
            Map<String, String> userMap = new Map<String, String>();
            For(Performance_Prod_User_ID_Mapping__c user : users){
            	userMap.put (user.UserId__c, user.User_Name__c);
            }            
            For(Performance_VFP_Detail__c detail : vfPages){
                
                // map foreign key for visual force page master record
                if (vfpMap.containsKey(detail.PageName__c)) {
                    detail.Performance_VFP__c = vfpMap.get(detail.PageName__c);
                }
                else {
                    // New page found.  Add a new master record and map this child to that new master
                    Performance_VFP__c pageMaster = new Performance_VFP__c();
                    pageMaster.Name = detail.pagename__c;
                    vfpList.add(pageMaster);
                    detail.Performance_VFP__c = vfpMap.get('UNKNOWN');
                }
                
                // map foreign key for production user mappings
                if (userMap.containsKey(detail.Userid__c)) {
                    detail.Username__c = userMap.get(detail.Userid__c);
                }
                else {
                    // New user found.  Add a new master record and map this child to that new master
                    Performance_Prod_User_ID_Mapping__c newUser = new Performance_Prod_User_ID_Mapping__c();
                    newUser.UserId__c = detail.Userid__c;
                    newUser.User_Name__c = 'UNMAPPED PROD USER';
                    prodUserList.add(newUser);
                    detail.Username__c =  'UNMAPPED PROD USER';
                }
         
        	} // END FOR  
            insert prodUserList;
            insert vfpList;
 

        } // end OnBeforeInsert

} // end class