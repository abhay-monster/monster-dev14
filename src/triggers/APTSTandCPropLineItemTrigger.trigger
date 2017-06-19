/*
** @author : Apttus
** @date : 06/06/2016
** @description : Terms_and_Conditions_Proposal_Line_Item__c Trigger for before insert event. 
*/
trigger APTSTandCPropLineItemTrigger on Terms_and_Conditions_Proposal_Line_Item__c (before insert) {

    
    APTSTandCPropLineItemHandler handler;
          
    if(Trigger.isInsert && Trigger.isBefore){
          
        try{
           
            handler = new APTSTandCPropLineItemHandler();
            handler.OnBeforeInsert(trigger.new);
        }
        catch(BaseApplicationException bae){ 
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++) 
           Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }
                    
    }
}