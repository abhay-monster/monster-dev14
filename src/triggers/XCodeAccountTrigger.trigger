trigger XCodeAccountTrigger on XcodeAccount__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) { 
        
    // declare handler  
    XCodeAccountTriggerHandler handler ;
          
    if(Trigger.isInsert && Trigger.isBefore){
        // before insert event  
        try{
			
			// create new instance of UserTriggerHandler
			handler = new XCodeAccountTriggerHandler(Trigger.isExecuting, Trigger.size); 
			
			// call the on After Insert event handler
			handler.OnbeforeInsert(trigger.new);
        }
        catch(BaseApplicationException bae){
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
            trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }    
    }
    else if(Trigger.isInsert && Trigger.isAfter){ 
        // after insert event
        try{
            
            // create new instance of UserTriggerHandler
            handler = new XCodeAccountTriggerHandler(Trigger.isExecuting, Trigger.size); 
            
            // call the on After Insert event handler
            handler.OnAfterInsert(trigger.new, trigger.newMap);
			//Populating Account.Site_Number_of_Employees__c from XcodeAccount__c.Xcode_Employees__c 
			
        }
        catch(BaseApplicationException bae){
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
            trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }
        
    }
    else if(Trigger.isUpdate && Trigger.isBefore){      
        // before update event
        try{
             handler = new XCodeAccountTriggerHandler(Trigger.isExecuting, Trigger.size); 
			
			// call the on After Insert event handler
			handler.OnbeforeUpdate(trigger.new, trigger.oldMap);
        }catch(BaseApplicationException bae){
            for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
            Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
         
        try{
            // create new instance of UserTriggerHandler
             handler = new XCodeAccountTriggerHandler(Trigger.isExecuting, Trigger.size); 
            
            // call the on before update event handler
             handler.OnAfterUpdate(trigger.new, Trigger.oldMap);
             
        }catch(BaseApplicationException bae){
            for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
            Trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }
    }
    else if(Trigger.isDelete && Trigger.isBefore){
        // before delete event        
    }
    else if(Trigger.isDelete && Trigger.isAfter){ 
        // after delete event
        try{
            
            // create new instance of UserTriggerHandler
            handler = new XCodeAccountTriggerHandler(Trigger.isExecuting, Trigger.size); 
            
            // call the on After Insert event handler
            handler.OnAfterDelete(trigger.old, trigger.oldMap);
        }
        catch(BaseApplicationException bae){
           for(Integer iLoop=0;iLoop<Trigger.size;iLoop++)
            trigger.new[iLoop].addError(bae.UserFriendlyMessage);
        }  
    }
    else if(Trigger.isUnDelete){ 
        // undelete event        
    }   
}