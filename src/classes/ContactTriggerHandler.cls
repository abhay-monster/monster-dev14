public  class ContactTriggerHandler extends BaseTriggerHandler {

    final String CLASSNAME = '\n\n**** ContactTriggerHandler.METHODNAME()';
    private integer BatchSize = 0;
    private TriggerHelper helper;
    private static Integer RunCount = 0;
    public static Boolean PreventRecursion = false;
    public static Boolean ExecuteTriggers = true;
    public static Boolean isRunningTest = false;
    public static Boolean throwTestException = false;
    public static Boolean throwTestBAEException = false;
    public static Boolean throwTestExceptionAfter = false;
    public static Boolean throwTestBAEExceptionAfter = false;
    public Org_Settings__c orgSettings = Org_Settings__c.getInstance();
    public Integer cutoff = Integer.valueOf(orgSettings.Debug_Log_Record_Count_Cutoff__c); //JFreese Appirio S-435483 4/11/17
    public Id debugId = orgSettings.Debug_Log_Record_ID__c; //JFreese Appirio S-435483 4/11/17

/*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : ContactTriggerHandler handler = new ContactTriggerHandler(Trigger.isExecuting, Trigger.size);
*/
    public ContactTriggerHandler(boolean isExecuting, integer pTriggerSize){
        if(isRunningTest && Test.isRunningTest()){
            throw BaseApplicationException.NewException('ContactTriggerHandlerTest','Exception thrown','Test Method Error!');
        }
        // trigger is executing
        TriggerIsExecuting = isExecuting;

        // set batch size
        BatchSize = pTriggerSize;

            // intantiate new trigger helper
            helper = TriggerHelper.NewTriggerHelper();

        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. AccountTriggerHelper)
        */
    }

/*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description :  this method handles the 'before insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Contact objects
** @returns : nothing
*/
    public void OnBeforeInsert(Contact[] pContact){
        if (Personal_Settings__c.getInstance().trigger_contact__c==false || ExecuteTriggers == false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        if(UserInfo.getName() == 'Integration MAPP'){
            for(Contact c : pContact){
                System.debug('^^^ MAPP BeforeInsert Contact ' + c);
            }
        }

        //try{
            /*if(throwTestException){
                throw new apexLogHandler.For_Testing_Force_Exception();
            }
            if(throwTestBAEException){
                throw BaseApplicationException.NewException('ContactTriggerHandlerTest','Exception thrown','Test Method Error!');
            }*/
            //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){

                //Method to Manage Primary Sales and Service Contact.
                //helper.ManagePrimarySalesAndServiceContact(pContact);
                ContactTriggerHelper contactHelper = ContactTriggerHelper.NewTriggerHelper();
                contactHelper.ResetQueries();
                contactHelper.ContactList = pContact;
                contactHelper.ManagePrimarySalesAndServiceContact(pContact);
                contactHelper.SetPrimarySalesContact(pContact);
                contactHelper.setPrimaryBillCon(pContact);
                contactHelper.validatePrimarySalesContact(pContact);
                contactHelper.updateContactFieldsFromMAPP(pContact);
                contactHelper.AssignContactFromMAPP(pContact);
                contactHelper.populateOrganization(pContact,null);
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

        for(Contact c : pContact){
            system.debug('^^^ ContactTriggerHandler End of OnBeforeInsert - pContact owner=' + c.ownerId);
        }

        if(UserInfo.getName() == 'Integration MAPP'){
            for(Contact c : pContact){
                System.debug('^^^ MAPP End of BeforeInsert Contact ' + c);
            }
        }
    }

/*
** @author : Cloud Sherpas Inc.
** @date : 03/07/2014
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of Contact objects
** @returns : nothing
*/
    public void OnAfterInsert(Contact[] pContact,map<ID, Contact> pContactIdNewContactMap){

         //System.debug('check list in handler '+pContact[0].Related_Case__c+'2nd '+pContact[1].Related_Case__c+'3rd '+pContact[2].Related_Case__c);
        if (Personal_Settings__c.getInstance().trigger_contact__c==false || ExecuteTriggers == false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //try{
            /*if(throwTestBAEExceptionAfter){
                throw BaseApplicationException.NewException('ContactTriggerHandlerTest','Exception thrown','Test Method Error!');
            }
            if(throwTestExceptionAfter){
                throw new apexLogHandler.For_Testing_Force_Exception();
            }*/
            //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>
                ContactTriggerHelper contactHelper = ContactTriggerHelper.NewTriggerHelper();
                contactHelper.ResetQueries();
                contactHelper.ContactList = pContact;
               contactHelper.UpdatePrimaryAgencyContactOfRelatedAccounts(pContact, null);
                //contactHelper.SetPrimarySalesContact(pContact,pContactIdNewContactMap);
                //

                contactHelper.associateContactToRelatedCase(pContact, pContactIdNewContactMap);
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */

                contactHelper.uncheckOtherPrimaryBillingContacts(pContact);//AP
                contactHelper.setAccountRecordPrimaryBillingContact(pContact);

                if(UserInfo.getName() == 'Integration MAPP'){
                    for(Contact c : pContact){
                        System.debug('^^^ MAPP AfterInsert Contact ' + c);
                    }
                    contactHelper.fixEcomm(pContact);
                }
            //}
       // }
        /*catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }*/
        for(Contact c : pContact){
            system.debug('^^^ ContactTriggerHandler End of OnAfterInsert - pContact owner=' + c.ownerId);
        }
    }

/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'before update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Contact objects, array of new Contact object, map of new Contacts, map of old Contacts
**  @returns : nothing
*/    public void OnBeforeUpdate(Contact[] pOldContacts, Contact[] pUpdatedContacts, map<ID, Contact> pContactIdToOldContactMap, map<ID, Contact> pContactIdToUpdatedContactMap){

        if (Personal_Settings__c.getInstance().trigger_contact__c==false || ExecuteTriggers == false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if(ContactTriggerHandler.RunCount > 1 && PreventRecursion){
            system.debug('^^^ ContactTriggerHandler Bypassing OnBeforeUpdate Runcount=' + ContactTriggerHandler.RunCount + ', PreventRecursion=' + PreventRecursion);
            return;
        }

        if(UserInfo.getName() == 'Integration MAPP'){
            for(Contact c : pUpdatedContacts){
                System.debug('^^^ MAPP BeforeUpdate Contact ' + c);
            }
        }

        //try{
            /*if(throwTestBAEException){
                throw BaseApplicationException.NewException('ContactTriggerHandlerTest','Exception thrown','Test Method Error!');
            }
            if(throwTestException){
                throw new apexLogHandler.For_Testing_Force_Exception();
            }*/
            system.debug(ExecuteTriggers+' '+IsTriggerContext);
            //if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){

                //Method to Manage Primary Sales and Service Contact.
                list<contact> UpdatedSalesContacts = new list<contact>();
                list<contact> UpdatedServiceContacts = new list<contact>();
                ContactTriggerHelper contactHelper = ContactTriggerHelper.NewTriggerHelper();
                contactHelper.ResetQueries();
                contactHelper.ContactList = pUpdatedContacts;
                //Method to Manage Primary Sales and Service Contact.
                for(Contact cnt: pUpdatedContacts){
                    if (pUpdatedContacts.size() <= cutoff || cnt.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                        system.debug('AlesS: in ContactTriggerhandler.OnBeforeUpdate looping thru contacts. Cnt = ' + cnt.LastName + ', Ac:' + cnt.Account + ',PrSales: ' + cnt.PrimarySalesContact__c + ',PrService: ' + cnt.PrimaryServiceContact__c);
                    }
                    if(pContactIdToOldContactMap.get(cnt.id).PrimarySalesContact__c != pContactIdToUpdatedContactMap.get(cnt.id).PrimarySalesContact__c ){
                        UpdatedSalesContacts.add(cnt);
                    }
                    if(pContactIdToOldContactMap.get(cnt.id).PrimaryServiceContact__c!= pContactIdToUpdatedContactMap.get(cnt.id).PrimaryServiceContact__c){
                        UpdatedServiceContacts.add(cnt);
                    }
                }

                if(!UpdatedSalesContacts.isEmpty()){
                    contactHelper.ManagePrimarySalesAndServiceContact(UpdatedSalesContacts);
                }

                if(!UpdatedServiceContacts.isEmpty()){
                    contactHelper.ManagePrimarySalesAndServiceContact(UpdatedServiceContacts);
                }

                contactHelper.UpdateValidationPrimarySalesContact(pUpdatedContacts,pContactIdToOldContactMap);
                //try{
                contactHelper.updateContactFieldsFromMAPP(pUpdatedContacts);
                //}catch(Exception dmlex){
                //    System.Debug('^^^ Contact EXCEPTION: ' + dmlex.getMessage());
                //    throw BaseApplicationException.NewException(METHODNAME, dmlex.getmessage(), 'Failed to update Owner. Please see system log for details.');
                //}
                contactHelper.populateOrganization(pUpdatedContacts,pContactIdToOldContactMap);
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
        for(Contact c : pUpdatedContacts){
            if (pUpdatedContacts.size() <= cutoff || c.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                system.debug('^^^ ContactTriggerHandler End of OnBeforeUpdate - pUpdatedContact owner=' + c.ownerId);
            }
        }
    }
/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'after update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Contact objects, array of new Contact object, map of new Contacts, map of old Contacts
**  @returns : nothing
*/
    public void OnAfterUpdate(Contact[] pOldContacts, Contact[] pUpdatedContacts, map<ID, Contact> pContactIdToOldContactMap, map<ID, Contact> pContactIdToUpdatedContactMap){
         if (Personal_Settings__c.getInstance().trigger_contact__c==false || ExecuteTriggers == false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if(ContactTriggerHandler.RunCount > 1 && PreventRecursion){
            system.debug('^^^ ContactTriggerHandler Bypassing OnAfterUpdate Runcount=' + ContactTriggerHandler.RunCount + ', PreventRecursion=' + PreventRecursion);
            return;
        }

        //try{
            /*if(throwTestBAEExceptionAfter){
                throw BaseApplicationException.NewException('ContactTriggerHandlerTest','Exception thrown','Test Method Error!');
            }
            if(throwTestExceptionAfter){
                throw new apexLogHandler.For_Testing_Force_Exception();
            }*/
            //if(ExecuteTriggers && IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>
                ContactTriggerHelper contactHelper = ContactTriggerHelper.NewTriggerHelper();
                contactHelper.ResetQueries();
                contactHelper.ContactList = pUpdatedContacts;
                contactHelper.UpdatePrimaryAgencyContactOfRelatedAccounts(pUpdatedContacts, pContactIdToOldContactMap);
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */
                contactHelper.uncheckOtherPrimaryBillingContacts(pUpdatedContacts);// AP I-159816
                contactHelper.setAccountRecordPrimaryBillingContact(pUpdatedContacts);
		        String usrName = UserInfo.getName();
                System.debug('UserInfo getting Name:' +usrName);
                if(UserInfo.getName() == 'Integration MAPP'){
                    for(Contact c : pUpdatedContacts){
                        System.debug('^^^ MAPP AfterUpdate Contact ' + c);
                    }
                    contactHelper.fixEcomm(pUpdatedContacts);
                }
            //}
        //}
        /*catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }*/
        for(Contact c : pUpdatedContacts){
            if (pUpdatedContacts.size() <= cutoff || c.Id == debugId){ //JFreese Appirio S-435483 4/11/17
                system.debug('^^^ ContactTriggerHandler End of OnAfterUpdate - pUpdatedContact owner=' + c.ownerId);
            }
        }
    }

/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'before delete' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Contact objects, map of old Contacts
**  @returns : nothing
*/

/*  Author : Piyush Jain
    Company : Appirio
    Comment : Commenting out OnBeforeDelete Method as it is not called by ContactTrigger
*/
     /*public void OnBeforeDelete(Contact[] pOldContacts, map<ID, SObject> pContactMapOld){
        if (Personal_Settings__c.getInstance().trigger_contact__c==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */  /*
            }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    } */

/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'after delete' event for the trigger; it's purpose is to ...
**  @paramaters : array of old Contact objects, map of old Contacts
**  @returns : nothing
*/
    public void OnAfterDelete(Contact[] pOldContacts, map<ID, Contact> pContactMapOld){
        if (Personal_Settings__c.getInstance().trigger_contact__c==false || ExecuteTriggers == false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //try{
            /*if(throwTestBAEException){
                throw BaseApplicationException.NewException('ContactTriggerHandlerTest','Exception thrown','Test Method Error!');
            }
            if(throwTestException){
                throw new apexLogHandler.For_Testing_Force_Exception();
            }*/
            //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>
                ContactTriggerHelper contactHelper = ContactTriggerHelper.NewTriggerHelper();
                contactHelper.ResetQueries();
                contactHelper.ContactList = pOldContacts;
                contactHelper.RemovePrimaryAgencyContactOfRelatedAccounts(pOldContacts, null);
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
    }

/*
**  @author : Cloud Sherpas Inc.
**  @date : 03/07/2014
**  @description :  this method handles the 'Undeleted' event for the trigger; it's purpose is to ...
**  @paramaters : array of new Contact object
**  @returns : nothing
*/
 /*public void OnUndeleted(Contact[] pUndeletedContacts){
        if (Personal_Settings__c.getInstance().trigger_contact__c==false){
            return; // If triggers are off, then exit the method
        }
        final string METHODNAME = CLASSNAME.replace('METHODNAME','OnUndeleted');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        try{
            //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                // <write code here>
                /*
                    note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                           and call the methods from handler.
                */ /*
            //}
        }
        catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
        }
    } */
}