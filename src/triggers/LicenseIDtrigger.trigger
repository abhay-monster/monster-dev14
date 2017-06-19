trigger LicenseIDtrigger on LicenseID__c (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {
    // declare handler
    LicenseIDTriggerHandler handler ;

    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event
            // create new instance of UserTriggerHandler
            handler = new LicenseIDTriggerHandler(Trigger.isExecuting, Trigger.size);

            // call the on After Insert event handler
            handler.OnbeforeInsert(trigger.new);
    }
        else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event

            handler = new LicenseIDTriggerHandler(Trigger.isExecuting, Trigger.size);

            // call the on after insert event handler
            handler.OnAfterInsert(Trigger.new, Trigger.newMap);

    }

    /*  Following code is not used anymore So commented out */
    /*
    else if(Trigger.isInsert && Trigger.isAfter){
        // after insert event
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        // before delete event
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        // after delete event
    }
    else if(Trigger.isUnDelete){
        // undelete event
    }  */
}