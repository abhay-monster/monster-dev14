/*
** @author :Apttus
** @date : 06/06/2016
** @description : Terms_and_Conditions_Proposal_Line_Item__c trigger class to handle CRUD events.
*/
public class APTSTandCPropLineItemHandler {

    
     private APTSTandCPropLineItemHelper helper;
    
    public APTSTandCPropLineItemHandler(){

        helper = APTSTandCPropLineItemHelper.NewTriggerHelper();
      
    }
    
    public void OnBeforeInsert(Terms_and_Conditions_Proposal_Line_Item__c[] TandCList){
    
       helper.populateTandC(TandCList);
    }
    
}