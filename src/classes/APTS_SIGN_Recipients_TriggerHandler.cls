public with sharing class APTS_SIGN_Recipients_TriggerHandler  extends BaseTriggerHandler{
    
    final String CLASSNAME = '\n\n**** APTS_SIGN_Recipients_TriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private APTS_SIGN_Recipients_TriggerHelper helper;
    public static Boolean ExecuteTriggers = true;
    private static Integer RunCount = 0;
    public static Boolean PreventRecursion = true;
    
       public APTS_SIGN_Recipients_TriggerHandler(boolean isExecuting, integer pTriggerSize) {
        
        // trigger is executing
        TriggerIsExecuting = isExecuting;
        
        // set batch size
        BatchSize = pTriggerSize;
        
        // set current User profile
        Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];
        system.debug(' currentUserProfile  :'+currentUserProfile);
        
        // intantiate new trigger helper
        helper = APTS_SIGN_Recipients_TriggerHelper.NewTriggerHelper(currentUserProfile.Name); 
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }
    
    public boolean OnBeforeInsert(echosign_dev1__SIGN_Recipients__c[] RecipientsList, MAP<id,echosign_dev1__SIGN_Recipients__c> OldRecipientsMAP) {
            final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            
            try { 
                if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)) {
                    
                    
                    If(!helper.CheckContact(RecipientsList))
                    {
                        System.debug('OnBeforeUpdate Return False');
                        return false;
                    }       
                       /*
    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
    and call the methods from handler.
    */              
                }               
            } catch(BaseApplicationException bae) {
                throw bae;
            } catch(Exception ex){                
                throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
            }
        return true;
    }
    
      public boolean OnBeforeUpdate(echosign_dev1__SIGN_Recipients__c[] RecipientsList, MAP<id,echosign_dev1__SIGN_Recipients__c> OldRecipientsMAP) {
            final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
            system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
            
            try { 
                if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)) {
                    
                    
                    If(!helper.CheckContact(RecipientsList))
                    {
                        System.debug('OnBeforeUpdate Return False');
                        return false;
                    }       
                       /*
    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
    and call the methods from handler.
    */              
                }               
            } catch(BaseApplicationException bae) {
                throw bae;
            } catch(Exception ex){                
                throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
            }
        return true;
    }

}