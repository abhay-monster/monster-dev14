/**=====================================================================
 * Appirio, Inc
 * Class Name: UpdateCaseOwners
 * Description: Used in List view a button called "Assign To Me" on case
 * Created Date: [23/06/2015]
 * Created By: Gaurav Gupta (Appirio)
 *
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/

global class UpdateCaseOwners{

     /**
     * Method to determine if selected case's Owners contains any User .
     */      
      WebService static Integer determineCaseOwnership(Id[] caseIds) {
        list<Case> lstCases = [select OwnerId from case where ID IN :caseIds ];
        for(Case c : lstCases){
            String caseOwnerId = c.OwnerId;
            if(caseOwnerId.substring(0,3) == '005' )
                return 0;
        }
        return 1;
      }
  
     /**
     * Method to update the case owner
     */   
      WebService static string updateCaseOwnership(Id[] caseIds) {
      
      try{
        list<Case> lstCases = [select OwnerId from case where ID IN :caseIds ];
        list<Case> lstCasesToUpdate = new list<case>();
        
        for(Case c : lstCases){
            if(c.ownerId != UserInfo.getUserId()){
               c.ownerId = UserInfo.getUserId();
               lstCasesToUpdate.add(c);
            }
        }
        
           if(lstCasesToUpdate.size() > 0){
             update lstCasesToUpdate;
           }
           
         return 'Success';
        } catch(exception e){
        return 'Some Error Occured';
        }
      
      }
  
}