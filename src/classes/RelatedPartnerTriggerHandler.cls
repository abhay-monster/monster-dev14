/*
** @author : Cloud Sherpas Inc.
** @date : 03/27/2014
** @description : Opportunity trigger class to handle CRUD events. 
*/
public with sharing class RelatedPartnerTriggerHandler extends BaseTriggerHandler{
    final String CLASSNAME = '\n\n**** RelatedPartnerTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private RelatedPartnerTriggerHelper helper;

/*  
** @author : Cloud Sherpas Inc.
** @date : 03/27/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : RelatedPartnerTriggerHandler handler = new RelatedPartnerTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public RelatedPartnerTriggerHandler(boolean isExecuting, integer pTriggerSize){ 
        
        // trigger is executing
        TriggerIsExecuting = isExecuting;
        
        // set batch size
        BatchSize = pTriggerSize;
        
        // set current User profile
        Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];
        
        // intantiate new trigger helper
        helper = RelatedPartnerTriggerHelper.NewTriggerHelper(currentUserProfile.Name);
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. OpportunityTriggerHelper)
        */
    }
    
/*
** @author : Cloud Sherpas Inc.
** @date : 03/27/2014
** @description :  this method handles the 'before insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of RelatedPartner__c objects
** @returns : nothing
*/
    public void OnBeforeInsert(RelatedPartner__c[] pRelatedPartner){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>                  
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
            }               
        
    }

/*   
** @author : Cloud Sherpas Inc.
** @date : 03/27/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of RelatedPartner__c objects
** @returns : nothing
*/
    public void OnAfterInsert(RelatedPartner__c[] pRelatedPartner){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
                
      
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                
                helper.SetAccountPrimaryRelatedAgency(pRelatedPartner, true);
                                  
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */              
            }               
       
    }

/*    
**  @author : Cloud Sherpas Inc.
**  @date : 03/27/2014
**  @description :  this method handles the 'before update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old RelatedPartner__c objects, array of new RelatedPartner__c object, map of new Opportunities, map of old Opportunities
**  @returns : nothing
*/
    public void OnBeforeUpdate(RelatedPartner__c[] pOldRelatedPartners, RelatedPartner__c[] pUpdatedRelatedPartners, map<ID, RelatedPartner__c> RelatedPartnerMapNew, map<ID, RelatedPartner__c> RelatedPartnerMapOld){       
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
       
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){              
                // <write code here>                
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */   
                //helper.updatePrimaryAgencyContact(pOldRelatedPartners);  
                //helper.SetAccountPrimaryRelatedAgency(pUpdatedRelatedPartners);         
            }
            
    }
/*   
**  @author : Cloud Sherpas Inc.
**  @date : 03/27/2014
**  @description :  this method handles the 'after update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old RelatedPartner__c objects, array of new RelatedPartner__c object, map of new Opportunities, map of old Opportunities
**  @returns : nothing
*/
    public void OnAfterUpdate(RelatedPartner__c[] pNewRelatedPartners){
         
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
      
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){              
                // <write code here>                   
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
                //update the billing agency field of Strategic account plan  
                //helper.updateBillingAgency(pNewRelatedPartners);

                //helper.updatePrimaryAgencyContact(pNewRelatedPartners); 
                helper.SetAccountPrimaryRelatedAgency(pNewRelatedPartners, false);      
            }
        
    }

/*  
**  @author : Cloud Sherpas Inc.
**  @date : 03/27/2014
**  @description :  this method handles the 'before delete' event for the trigger; it's purpose is to ...
**  @paramaters : array of old RelatedPartner__c objects, map of old Opportunities
**  @returns : nothing
*/
    public void OnBeforeDelete(RelatedPartner__c[] pOldRelatedPartners, map<ID, RelatedPartner__c> pRelatedPartnerMapOld){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
      
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */      
            }
       
    }

/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/27/2014
**  @description :  this method handles the 'after delete' event for the trigger; it's purpose is to ...
**  @paramaters : array of old RelatedPartner__c objects, map of old Opportunities
**  @returns : nothing
*/  
    public void OnAfterDelete(RelatedPartner__c[] pOldRelatedPartners, map<ID, RelatedPartner__c> pRelatedPartnerMapOld){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
       
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>
                //remove Primary Agency Contact on related Account__c
                helper.removePrimaryAgencyContactFromAccount(pOldRelatedPartners);
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
                //update the billing agency field of Strategic account plan
                //helper.updateBillingAgency(pOldRelatedPartners);      
            }
       
    }

/*  
**  @author : Cloud Sherpas Inc.
**  @date : 03/27/2014
**  @description :  this method handles the 'Undeleted' event for the trigger; it's purpose is to ...
**  @paramaters : array of new RelatedPartner__c object
**  @returns : nothing
*/       
    public void OnUndeleted(RelatedPartner__c[] pUndeletedRelatedPartners){
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnUndeleted');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        
            if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */      
            }
       
    } 
}