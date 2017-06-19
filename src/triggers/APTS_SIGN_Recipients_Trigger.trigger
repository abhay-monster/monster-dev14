trigger APTS_SIGN_Recipients_Trigger on echosign_dev1__SIGN_Recipients__c (before Insert, before update) {
    
    APTS_SIGN_Recipients_TriggerHandler Handler;
    If(Trigger.isbefore && Trigger.ISInsert)
    {
           ///try {
            handler = new APTS_SIGN_Recipients_TriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            If(!handler.OnBeforeInsert(trigger.new , trigger.oldMAp))
            {
                   for(Integer iLoop = 0; iLoop < Trigger.size; iLoop++) 
                    Trigger.new[iLoop].addError('Contact does not belong to related account or Related Partners/ Agency.');
            }
        /*}
        catch(BaseApplicationException bae) { 
           for(Integer iLoop = 0; iLoop < Trigger.size; iLoop++) 
            Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        } */
    }
    
    If(Trigger.isbefore && 
        Trigger.isUpdate)
    {
           //try {
            handler = new APTS_SIGN_Recipients_TriggerHandler(Trigger.isExecuting, Trigger.size);
                        
            // call the on before update event handler
            If(!handler.OnBeforeUpdate(trigger.new , trigger.oldMAp))
            {
                   for(Integer iLoop = 0; iLoop < Trigger.size; iLoop++) 
                    Trigger.new[iLoop].addError('Contact does not belong to related account or Related Partners/ Agency.');
            }
       /* }
        catch(BaseApplicationException bae) { 
           for(Integer iLoop = 0; iLoop < Trigger.size; iLoop++) 
            Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }*/ 
    }
    
    

}