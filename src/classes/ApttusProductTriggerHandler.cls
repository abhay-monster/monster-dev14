/*
** @author : Cloud Sherpas Inc.
** @date : 11/18/2014
** @description : ProductConfigration trigger class to handle CRUD events. 
*/
public with sharing class ApttusProductTriggerHandler extends BaseTriggerHandler{

    final String CLASSNAME = '\n\n**** ApttusProductTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private ProductTriggerHelper helper;
    public static Boolean ExecuteTriggers = true;
    private static Integer RunCount = 0;
    public static Boolean PreventRecursion = true;

/*  
** @author : Cloud Sherpas Inc.
** @date : 11/18/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : ApttusProductTriggerHandler handler = new ApttusProductConfigTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public ApttusProductTriggerHandler(boolean isExecuting, integer pTriggerSize){
        
        // trigger is executing
        TriggerIsExecuting = isExecuting;
        
        // set batch size
        BatchSize = pTriggerSize;
        
        // set current User profile
        //Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];
        
        // intantiate new trigger helper
        helper = ProductTriggerHelper.NewTriggerHelper();
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }


/*   
** @author : Cloud Sherpas Inc.
** @date : 09/18/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of product2 objects
** @returns : nothing
*/
    public void OnBeforeInsert(Product2[] pApttusProductList){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //Skip updating Oppty in Cloning the Proposal
        //OpportunityTriggerHandler.SKIP_OPPORTUNITY_UPDATE = true;
                
        //try{
            //if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                helper.Sellingcountry_Expand(pApttusProductList);
            //}               
        //}
        /*catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }*/
    }

/*   
** @author : Cloud Sherpas Inc.
** @date : 11/18/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Product2 objects
** @returns : nothing
*/

/* author : Piyush Jain
** date : 17/07/2015
** description :  Commenting OnAfterUpdate Method since it does nothing 
*/
public void OnAfterInsert(Product2[] pNewApttusProduct, map<Id, Product2> pOldApttusProductMap){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
                
        try{
            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                //helper.populateOrderQuotaType(pNewApttusProduct);
                
            }               
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
}
    
/*   
** @author : Cloud Sherpas Inc.
** @date : 11/18/2014
** @description :  this method handles the 'before Update' event for the trigger; it's purpose is to ...
** @paramaters : an array of product2 objects
** @returns : nothing
*/
    public void OnBeforeUpdate( Product2[] pOldApttusProductList, Product2[] pUpdatedApttusProductList, map<Id, Product2> pUpdatedApttusProductMap, map<Id, Product2> pOldApttusProductMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
        system.debug('**** OnBeforeUpdate prevent Recursion RunCount:'+ ApttusProductTriggerHandler.RunCount + ' PreventRecursion:' + PreventRecursion);
        if(ApttusProductTriggerHandler.RunCount > 0 && PreventRecursion){
            return;
        }
        //try{
            //if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                
                helper.Sellingcountry_Expand(pUpdatedApttusProductList);
                
                RunCount++;
                system.debug('Apttus Proposal Handler Run Count: ' + RunCount); 
            //}               
        //}
        /*catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }*/
    }
    
/*   
** @author : Cloud Sherpas Inc.
** @date : 11/18/2014
** @description :  this method handles the 'after update' event for the trigger; it's purpose is to ...
** @paramaters : an array of Product2 objects
** @returns : nothing
*/

/* author : Piyush Jain
** date : 17/07/2015
** description :  Commenting OnAfterUpdate Method since it does nothing 
*/

public void OnAfterUpdate(Product2[] pNewApttusProduct, map<Id, Product2> pOldApttusProductMap){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug('**** OnAfterUpdate prevent Recursion RunCount:'+ ApttusProductTriggerHandler.RunCount + ' PreventRecursion:' + PreventRecursion);
        system.debug('in handler ApttusProductTriggerHandler onAfterupdate');
        if(ApttusProductTriggerHandler.RunCount > 1 && PreventRecursion){
            system.debug('*** SKIP Trigger Product OnAfterUpdate.');
            return;
        }
        System.debug('Trigger context:\n ExecuteTriggers :'+ExecuteTriggers+'\nIsTriggerContext :'+IsTriggerContext+'\nIsVisualforcePageContext :'+IsVisualforcePageContext+'\n IsWebServiceContext :'+IsWebServiceContext+'\nIsExecuteAnonymousContext: '+IsExecuteAnonymousContext);
        
        try{
            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
               
                //helper.populateOrderQuotaType(pNewApttusProduct);
                
            }               
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            System.debug('Error'+ex.getLineNumber()+ex.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
            
        }
}
    
/*   
** @author : Cloud Sherpas Inc.
** @date : 11/18/2014
** @description :  this method handles the 'after delete' event for the trigger; it's purpose is to ...
** @paramaters : an array of Product2 objects
** @returns : nothing
*/
/* author : Piyush Jain
** date : 17/07/2015
** description :  Commenting onAfterDelete Method since it does nothing 
*/

//public void OnAfterDelete(Product2[] pApttusProduct){
        
        //final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterDlete');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
                
        //try{
            //if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */              
            //}               
        //}
        /*catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }*/
    //}
}