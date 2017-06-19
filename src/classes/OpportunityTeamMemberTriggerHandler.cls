/*
** @author : Cloud Sherpas Inc.
** @date : 03/31/2014
** @description :OpportunityTeamMember trigger class to handle CRUD events.
*/
public without sharing class OpportunityTeamMemberTriggerHandler extends BaseTriggerHandler{

  final String CLASSNAME = '\n\n**** OpportunityTeamMemberTriggerHandler .METHODNAME()';
    private integer BatchSize = 0;
    private OpportunityTeamMemberTriggerHelper helper;
    private static Integer RunCount = 0;
    public static Boolean PreventRecursion = false;
    public String msg = '';
    private  static String CurrentUserProfileName {
        get {
                if(CurrentUserProfileName == null){

                    Profile p = [Select Name From Profile where Id = :UserInfo.getProfileId()];
                    CurrentUserProfileName = p.name;
                }


                return CurrentUserProfileName;
        }
        set;
    }

/*
** @author : Cloud Sherpas Inc.
** @date : 03/31/2014
** @description : the class constructor method
** @paramaters : a Boolean value indicating if a trigger is executing or not, an Integer value indicating the number of records in the batch/list
** @returns : nothing
** @sample call : OpportunityTeamMemberTriggerHandler handler = new OpportunityTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);
*/

    public OpportunityTeamMemberTriggerHandler(boolean isExecuting, integer pTriggerSize)
    {
    // trigger is executing
        TriggerIsExecuting = isExecuting;

    // set batch size
        BatchSize = pTriggerSize;

    // set current User profile
        //Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];

    // intantiate new trigger helper
       helper = OpportunityTeamMemberTriggerHelper.NewTriggerHelper(CurrentUserProfileName);
    /*
      note - develper may want to create new or extent the base helper class specific to an sObject (i.e. OpportunityTeamMemberTriggerHelper)
    */
    }

/*
** @author : Cloud Sherpas Inc.
** @date : 3/31/2014
** @description :  this method handles the 'before insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of OpportunityTeamMember objects
** @returns : nothing
*/

/*
** author : Piyush Jain - Appirio
** date : 07/20/2014
** description :  This Method does hence commenting it
*/
public void OnBeforeInsert(OpportunityTeamMember__c[] pOpportunityTeamMember){

      final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Team_Members__c ==false){
            return; // If triggers are off, then exit the method
        }

        //updateOpportunityAllocationPercentOnOpp( pOpportunityTeamMember , (Map<Id,OpportunityTeamMember__c>)Trigger.oldMap);

        /*for(OpportunityTeamMember__c teamMember : pOpportunityTeamMember){
            teamMember.System_Generated__c = true;
        }*/

              //try{
                //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
                    //helper.validateOpportunityTeamMemberInsertion(pOpportunityTeamMember);
                /*
                  note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                         and call the methods from handler.
                */
                //}
              /*}
              catch(BaseApplicationException bae){
                throw bae;
              }
              catch(Exception ex){
                throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
              }*/


  }

/*
** @author : Cloud Sherpas Inc.
** @date : MM/DD/YYYY
** @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
** @paramaters : an array of OpportunityTeamMember objects
** @returns : nothing
*/
    public void OnAfterInsert(OpportunityTeamMember__c[] pOpportunityTeamMember){

      final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Team_Members__c ==false){
            return; // If triggers are off, then exit the method
        }

      //try{
        //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
            helper.removeSameTeamMember(pOpportunityTeamMember);
            helper.createStandardOpportunityTeamMembers(pOpportunityTeamMember);
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
**  @date : MM/DD/YYYY
**  @description :  this method handles the 'before update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old OpportunityTeamMember objects, array of new OpportunityTeamMember object, map of new OpportunityTeamMembers, map of old OpportunityTeamMembers
**  @returns : nothing
*/
/*

/*
**  @author : Piyush Jain - Appirio
**  @date : 20/07/2015
**  @description :  Since this method is doing Nothing Hence Commenting it.
*/


    //public void OnBeforeUpdate(OpportunityTeamMember__c[] pOldOpportunityTeamMembers, OpportunityTeamMember__c[] pUpdatedOpportunityTeamMembers ,map<ID,SObject> pOpportunityTeamMemberMapOld ,map<ID, SObject> OpportunityTeamMemberMapNew ){
        //updateOpportunityAllocationPercentOnOpp( pUpdatedOpportunityTeamMembers , (Map<Id,OpportunityTeamMember__c>)pOpportunityTeamMemberMapOld);

    //}
/*
**  @author : Cloud Sherpas Inc.
**  @date : MM/DD/YYYY
**  @description :  this method handles the 'after update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old OpportunityTeamMember objects, array of new OpportunityTeamMember object, map of new OpportunityTeamMembers, map of old OpportunityTeamMembers
**  @returns : nothing
*/
    public void OnAfterUpdate(OpportunityTeamMember__c[] pOldOpportunityTeamMembers, OpportunityTeamMember__c[] pUpdatedOpportunityTeamMembers ,map<ID,SObject> pOpportunityTeamMemberMapOld ,map<ID, SObject> OpportunityTeamMemberMapNew ){

      final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdate');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Team_Members__c ==false){
            return; // If triggers are off, then exit the method
        }

      //try{
        //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
            if(pUpdatedOpportunityTeamMembers != null){
              helper.synchronizeCustomOppTeamMembersWithStandardOppTeamMembers(pUpdatedOpportunityTeamMembers);
             }

        /*
          note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                 and call the methods from handler.
        */
            //helper.removeSameTeamMember(pUpdatedOpportunityTeamMembers);
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
**  @date : MM/DD/YYYY
**  @description :  this method handles the 'before delete' event for the trigger; it's purpose is to ...
**  @paramaters : array of old OpportunityTeamMember objects, map of old OpportunityTeamMembers
**  @returns : nothing
*/

/*
** author : Piyush Jain - Appirio
** date : 07/20/2015
** description :  The onBeforeDelete Method of Handler Class is not calling the OnBeforeDelete method of Helper Class Rather is calling AfterUpdate method, hence a confusion , hence commenting.
*/

public void OnBeforeDelete(OpportunityTeamMember__c[] pOldOpportunityTeamMembers, map<ID, SObject> pOpportunityTeamMemberMapOld){

      final string METHODNAME = CLASSNAME.replace('METHODNAME','OnBeforeDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Team_Members__c ==false){
            return; // If triggers are off, then exit the method
        }

        //updateOpportunityAllocationPercentOnOpp(pOldOpportunityTeamMembers , null);
      //try{
        //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
        system.debug('^^^CHECK^^^'+ PreventRecursion);
            /*if(!PreventRecursion){
                helper.ValidationToAvoidDeletionOfPrimarySalesRep(pOldOpportunityTeamMembers);*/
            //}
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
    **  @author : Appirio
    **  @date : 14/10/2015
    **  @description :  this method handles the the Allocation % on parent Opp
    **  @paramaters : array of new OpportunityTeamMember objects, map of old OpportunityTeamMembers
    **  @returns : nothing
    */

    /*private void updateOpportunityAllocationPercentOnOpp( OpportunityTeamMember__c[] pUpdatedOpportunityTeamMembers,map<ID, OpportunityTeamMember__c> OpportunityTeamMemberMapOld){

        Set<Id> setOppIds = new Set<Id>();
        for(OpportunityTeamMember__c  oppTeamMember : pUpdatedOpportunityTeamMembers){
            setOppIds.add(oppTeamMember.Opportunity__c);
        }
        Set<Id> setOpportunity = new Set<Id>();
        Map<id , Opportunity > mapOppMapRelatedToTeamMember = new Map<id,Opportunity>([Select Allocation_1__c ,
                                                                                       Allocation_2__c ,
                                                                                       Allocation_3__c ,
                                                                                       Allocation_4__c,
                                                                                       Allocation_5__c,
                                                                                       Allocation_6__c,
                                                                                       Allocation_7__c,
                                                                                       Allocation_8__c,
                                                                                       Allocation_9__c,
                                                                                       Allocation_10__c
                                                                                       From Opportunity
                                                                                       Where Id In : setOppIds]);
        for(OpportunityTeamMember__c  oppTeamMember : pUpdatedOpportunityTeamMembers){
            Opportunity relatedOpp = mapOppMapRelatedToTeamMember.get(oppTeamMember.Opportunity__c);

            if(trigger.isDelete){
                if(oppTeamMember.Allocation_Index__c ==1)
                    relatedOpp.Allocation_1__c = Null;
                if(oppTeamMember.Allocation_Index__c ==2)
                    relatedOpp.Allocation_2__c = Null;
                if(oppTeamMember.Allocation_Index__c ==3)
                    relatedOpp.Allocation_3__c = Null;
                if(oppTeamMember.Allocation_Index__c ==4)
                    relatedOpp.Allocation_4__c = Null;
                if(oppTeamMember.Allocation_Index__c ==5)
                    relatedOpp.Allocation_5__c = Null;
                if(oppTeamMember.Allocation_Index__c ==6)
                    relatedOpp.Allocation_6__c = Null;
                if(oppTeamMember.Allocation_Index__c ==7)
                    relatedOpp.Allocation_7__c = Null;
                if(oppTeamMember.Allocation_Index__c ==8)
                    relatedOpp.Allocation_8__c = Null;
                if(oppTeamMember.Allocation_Index__c ==9)
                    relatedOpp.Allocation_9__c = Null;
                if(oppTeamMember.Allocation_Index__c ==10)
                    relatedOpp.Allocation_10__c = Null;
            }else{

                if(oppTeamMember.Split__c != Null && (OpportunityTeamMemberMapOld == null || OpportunityTeamMemberMapOld.get(oppTeamMember.Id).Split__c != oppTeamMember.Split__c)){

                    if(relatedOpp.Allocation_1__c == Null || oppTeamMember.Allocation_Index__c == 1){
                        relatedOpp.Allocation_1__c = oppTeamMember.Split__c ;
                        oppTeamMember.Allocation_Index__c = 1;
                    }
                    else if (relatedOpp.Allocation_2__c == Null || oppTeamMember.Allocation_Index__c == 2){
                        relatedOpp.Allocation_2__c = oppTeamMember.Split__c ;
                        oppTeamMember.Allocation_Index__c = 2;
                    }
                    else if (relatedOpp.Allocation_3__c == Null || oppTeamMember.Allocation_Index__c == 3){
                        relatedOpp.Allocation_3__c = oppTeamMember.Split__c ;
                        oppTeamMember.Allocation_Index__c = 3;
                    }
                    else if (relatedOpp.Allocation_4__c == Null || oppTeamMember.Allocation_Index__c == 4){
                        relatedOpp.Allocation_4__c = oppTeamMember.Split__c ;
                        oppTeamMember.Allocation_Index__c = 4;
                    }
                    else if (relatedOpp.Allocation_5__c == Null || oppTeamMember.Allocation_Index__c == 5){
                        relatedOpp.Allocation_5__c = oppTeamMember.Split__c ;
                        oppTeamMember.Allocation_Index__c = 5;
                    }
                    else if (relatedOpp.Allocation_6__c == Null || oppTeamMember.Allocation_Index__c == 6){
                        relatedOpp.Allocation_6__c = oppTeamMember.Split__c ;
                        oppTeamMember.Allocation_Index__c = 6;
                    }
                    else if (relatedOpp.Allocation_7__c == Null || oppTeamMember.Allocation_Index__c == 7){
                        relatedOpp.Allocation_7__c = oppTeamMember.Split__c ;
                        oppTeamMember.Allocation_Index__c = 7;
                    }
                    else if (relatedOpp.Allocation_8__c == Null || oppTeamMember.Allocation_Index__c == 8){
                        relatedOpp.Allocation_8__c = oppTeamMember.Split__c ;
                        oppTeamMember.Allocation_Index__c = 8;
                    }
                    else if (relatedOpp.Allocation_9__c == Null || oppTeamMember.Allocation_Index__c == 9){
                        relatedOpp.Allocation_9__c = oppTeamMember.Split__c ;
                        oppTeamMember.Allocation_Index__c = 9;
                    }
                    else if (relatedOpp.Allocation_10__c == Null || oppTeamMember.Allocation_Index__c == 10){
                        relatedOpp.Allocation_10__c = oppTeamMember.Split__c ;
                        oppTeamMember.Allocation_Index__c = 10;
                    }
                }

            }
            setOpportunity.add(relatedOpp.id);
        }

        List<Opportunity> ListOfOppToBeUpdated = new List<Opportunity>();
        for(Opportunity opp : mapOppMapRelatedToTeamMember.values()){
            if(setOpportunity.contains(opp.id)){
                ListOfOppToBeUpdated.add(opp);
            }
        }

       //system.assert(false , setOpportunity +'>>>>>'+ListOfOppToBeUpdated );
        if(ListOfOppToBeUpdated.size() > 0)
            update ListOfOppToBeUpdated;
    }*/




    /*
    **  @author : Cloud Sherpas Inc.
    **  @date : MM/DD/YYYY
    **  @description :  this method handles the 'after delete' event for the trigger; it's purpose is to ...
    **  @paramaters : array of old OpportunityTeamMember objects, map of old OpportunityTeamMembers
    **  @returns : nothing
    */
    public void OnAfterDelete(OpportunityTeamMember__c[] pOldOpportunityTeamMembers, map<ID, SObject> pOpportunityTeamMemberMapOld){

      final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterDelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Team_Members__c ==false){
            return; // If triggers are off, then exit the method
        }

      //try{
        //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
          if(pOldOpportunityTeamMembers != null){
              helper.deleteStandardOpportunityTeamMembers(pOldOpportunityTeamMembers);
               msg = 'has been removed from Teaming Opportunity';
               //helper.sendEmailToDeleteOppTeamMember(pOldOpportunityTeamMembers,msg);
           }
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
**  @date : MM/DD/YYYY
**  @description :  this method handles the 'Undeleted' event for the trigger; it's purpose is to ...
**  @paramaters : array of new OpportunityTeamMember object
**  @returns : nothing
*/
/*
**  @author : Piyush Jain - Appirio
**  @date : 20/07/2015
**  @description :  this method does nothing and hence commenting it.
*/
  /*  public void OnUndeleted(OpportunityTeamMember__c[] pUndeletedOpportunityTeamMembers){

      final string METHODNAME = CLASSNAME.replace('METHODNAME','OnUndeleted');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

      try{
        if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
          // <write code here>
        /*
          note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                 and call the methods from handler.
        */
    /*    }
       }
      catch(BaseApplicationException bae){
        throw bae;
      }
      catch(Exception ex){
        throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
      }
    }*/


/*
**  @author : Cloud Sherpas Inc.
**  @date : 04/14/2014
**  @description :  this method handles the 'after delete' event for the trigger; it's purpose is to ...
**  @paramaters : array of old OpportunityTeamMember objects, map of old OpportunityTeamMembers
**  @returns : nothing
*/
  public void OnAfterDeleteStandardOppTeamMember(OpportunityTeamMember[] pOldOpportunityTeamMembers, map<ID, SObject> pOpportunityTeamMemberMapOld){

      final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterDeleteStandardOppTeamMember');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('@!@oppteammmember'+ OpportunityTeamMemberTriggerHandler.RunCount);
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Team_Members__c ==false){
            return; // If triggers are off, then exit the method
        }
        if(OpportunityTeamMemberTriggerHandler.RunCount > 0){
            return;
        }
      //try{
          //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){
               msg = 'has been removed from Teaming Opportunity';
               //helper.sendEmailStandardOppTeamMember(pOldOpportunityTeamMembers,msg);
                helper.UpdateoppSalesRepOndelete(pOldOpportunityTeamMembers);           ///added 29/10
         // helper.SetTeamingScenarioAndType(pOldOpportunityTeamMembers);
          RunCount++;

        /*
          note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                 and call the methods from handler.
        */
       //}
      /*}catch(BaseApplicationException bae){
        throw bae;
      }catch(Exception ex){
        throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
      }*/
    }
/*
**  @author : Cloud Sherpas Inc.
**  @date : 04/14/2014
**  @description :  this method handles the 'after insert' event for the trigger; it's purpose is to ...
**  @paramaters : array of old OpportunityTeamMember objects, map of old OpportunityTeamMembers
**  @returns : nothing
*/
public void OnAfterInsertStandardOppTeamMember(OpportunityTeamMember[] pOldOpportunityTeamMembers, map<ID, SObject> pOpportunityTeamMemberMapOld){
      system.debug('>>>>>>>>>>>>1' + msg );
      final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterInsertStandardOppTeamMember');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Team_Members__c ==false){
            return; // If triggers are off, then exit the method
        }
        if(OpportunityTeamMemberTriggerHandler.RunCount > 0){
        system.debug('>>>>>>>>>>>>2' + msg );
            return;
        }
        system.debug('>>>>>>>>>>>>3' + msg );

      //try{
         // if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){

           msg = 'has been added to Teaming Opportunity';
           system.debug('>>>>>>>>>>>>4' + msg );
           //helper.sendEmailStandardOppTeamMember(pOldOpportunityTeamMembers , msg);

         // helper.SetTeamingScenarioAndType(pOldOpportunityTeamMembers);
          RunCount++;

        /*
          note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                 and call the methods from handler.
        */
       //}
      /*catch(BaseApplicationException bae){
        throw bae;
      }catch(Exception ex){
        throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
      }*/
    }

/*
**  @author : Cloud Sherpas Inc.
**  @date : 04/14/2014
**  @description :  this method handles the 'after update' event for the trigger; it's purpose is to ...
**  @paramaters : array of old OpportunityTeamMember objects, map of old OpportunityTeamMembers
**  @returns : nothing
*/
  public void OnAfterUpdateStandardOppTeamMember(OpportunityTeamMember[] pOldOpportunityTeamMembers, map<ID, SObject> pOpportunityTeamMemberMapOld){

      final string METHODNAME = CLASSNAME.replace('METHODNAME','OnAfterUpdateStandardOppTeamMember');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        if (Personal_Settings__c.getInstance().Trigger_Opportunity_Team_Members__c ==false){
            return; // If triggers are off, then exit the method
        }
        if(OpportunityTeamMemberTriggerHandler.RunCount > 0){
            return;
        }

      //try{
          //if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){

         // helper.SetTeamingScenarioAndType(pOldOpportunityTeamMembers);
          RunCount++;
         //}

        /*
          note - if multiple specification are required for trigger event, developer may consider moving code to the helper class
                 and call the methods from handler.
        */
       //}
      /*catch(BaseApplicationException bae){
        throw bae;
      }catch(Exception ex){
        throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', ex);
      }*/
    }
}