/*
** @author : Ranjeet, Apttus Inc.
** @date : 11/05/2014
** @description :
*/
public with sharing class APTS_EchoSignAgreementTriggerHandler extends BaseTriggerHandler {

    final String CLASSNAME = '\n\n**** APTS_EchoSignAgreementTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private APTS_EchoSignAgreementTriggerHelper helper;
    public static Boolean ExecuteTriggers = true;
    private static Integer RunCount = 0;
    public static Boolean PreventRecursion = true;

    /*
    ** @author : Ranjeet, Apttus Inc.
    ** @date : 11/05/2014
    ** @description :
    ** @paramaters :
    ** @returns : nothing
    ** @sample call :
    */
    public APTS_EchoSignAgreementTriggerHandler(boolean isExecuting, integer pTriggerSize) {

        // trigger is executing
        TriggerIsExecuting = isExecuting;

        // set batch size
        BatchSize = pTriggerSize;

        // set current User profile
        Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];
        system.debug(' currentUserProfile  :'+currentUserProfile);

        // intantiate new trigger helper
        helper = APTS_EchoSignAgreementTriggerHelper.NewTriggerHelper(currentUserProfile.Name);
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }

    /*
    ** @author : Ranjeet, Apttus Inc.
    ** @date : 11/05/2014
    ** @description :
    ** @paramaters :
    ** @returns : nothing
    */
    public void OnAfterInsert(echosign_dev1__SIGN_Agreement__c[] pEchoSignAgreementList, MAP<id,echosign_dev1__SIGN_Agreement__c> OldEchoSignAgreementMAP) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try {
            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)) {
               helper.setContacts(pEchoSignAgreementList);

            }
        } catch(BaseApplicationException bae) {
            throw bae;
        } catch(Exception ex){
            System.Debug('....Exception in Handler Class .... '+ex);
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }

    /*
    ** @author : Ranjeet, Apttus Inc.
    ** @date : 11/05/2014
    ** @description :
    ** @paramaters :
    ** @returns : nothing
    */
    public void OnBeforeInsert(echosign_dev1__SIGN_Agreement__c[] pEchoSignAgreementList, MAP<id,echosign_dev1__SIGN_Agreement__c> OldEchoSignAgreementMAP) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try {
            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)) {
                helper.setAccountAndOpportunity(pEchoSignAgreementList);
              //  helper.setContactsOnEchosignAgreement(pEchoSignAgreementList);
                helper.setCCAddress(pEchoSignAgreementList,OldEchoSignAgreementMAP,'Insert');
                helper.setDefaultLanguague(pEchoSignAgreementList);

               //helper.setContacts(pEchoSignAgreementList);
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
    }

    public void OnBeforeUpdate(echosign_dev1__SIGN_Agreement__c[] pEchoSignAgreementList, MAP<id,echosign_dev1__SIGN_Agreement__c> OldEchoSignAgreementMAP) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try {
            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)) {
                helper.setCCAddress(pEchoSignAgreementList,OldEchoSignAgreementMAP,'Update');
                //helper.setContacts(pEchoSignAgreementList);
                helper.setDefaultDisclaimer(pEchoSignAgreementList);
           }
        } catch(BaseApplicationException bae) {
            throw bae;
        } catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }

    /*JFreese Appirio 4/12/17 S-473744  The afterUpdate is in Update_oppty_proposal_on_status_Signed.trigger
    public void OnAfterUpdate(echosign_dev1__SIGN_Agreement__c[] pEchoSignAgreementList, MAP<id,echosign_dev1__SIGN_Agreement__c> OldEchoSignAgreementMAP) {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try {
            if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)) {
                helper.createOrder(pEchoSignAgreementList,OldEchoSignAgreementMAP); //JFreese Appirio 4/12/17 S-473744
            }
        } catch(BaseApplicationException bae) {
            throw bae;
        } catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    }*/

}