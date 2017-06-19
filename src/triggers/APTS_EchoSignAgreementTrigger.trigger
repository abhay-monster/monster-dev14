trigger APTS_EchoSignAgreementTrigger on echosign_dev1__SIGN_Agreement__c (after insert, before insert, before Update) {

    // declare handler
    APTS_EchoSignAgreementTriggerHandler handler;

    if(Trigger.isInsert && Trigger.isBefore) {
        // before insert event

        try {
            handler = new APTS_EchoSignAgreementTriggerHandler(Trigger.isExecuting, Trigger.size);

            // call the on before update event handler
            handler.OnBeforeInsert(trigger.new , trigger.oldMAp);
        }
        catch(BaseApplicationException bae) {
           for(Integer iLoop = 0; iLoop < Trigger.size; iLoop++)
            Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }
    }

     if(Trigger.isInsert && Trigger.isAfter) {
        // after insert event

        try {
            handler = new APTS_EchoSignAgreementTriggerHandler(Trigger.isExecuting, Trigger.size);

            // call the on before update event handler
            handler.OnAfterInsert(trigger.new , trigger.oldMAp);
        }
        catch(BaseApplicationException bae) {
           for(Integer iLoop = 0; iLoop < Trigger.size; iLoop++)
            Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }
    }

    if(Trigger.isUpdate && Trigger.isBefore) {
        // before update event

        try {
            handler = new APTS_EchoSignAgreementTriggerHandler(Trigger.isExecuting, Trigger.size);

            // call the on before update event handler
            handler.OnBeforeUpdate(trigger.new, trigger.oldMAp);
        }
        catch(BaseApplicationException bae) {
           for(Integer iLoop = 0; iLoop < Trigger.size; iLoop++)
            Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }
    }

    /*JFreese Appirio 4/12/17 S-473744 Set this up, then discovered that ehe afterUpdate is in
      Update_oppty_proposal_on_status_Signed.trigger, no idea why.
    if(Trigger.isUpdate && Trigger.isAfter) {
        // after update event

        try {
            handler = new APTS_EchoSignAgreementTriggerHandler(Trigger.isExecuting, Trigger.size);

            // call the on before update event handler
            handler.OnAfterUpdate(trigger.new, trigger.oldMAp);
        }
        catch(BaseApplicationException bae) {
           for(Integer iLoop = 0; iLoop < Trigger.size; iLoop++)
            Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }
    }*/

}