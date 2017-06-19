/*
** @author : Cloud Sherpas Inc.
** @date : 03/31/2014
** @description : OpportunityTeamMember__c trigger class to handle CRUD events.
*/
public without sharing class OpportunityTeamMemberTriggerHelper{

   final String CLASSNAME = '\n\n**** OpportunityTeamMemberTriggerHandler .METHODNAME()';
   private String UserProfileName{get; private set;}

/*
** @author : Cloud Sherpas Inc.
** @date : 03/20/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the OpportunityTeamMemberTriggerHelper class
*/
    public static OpportunityTeamMemberTriggerHelper NewTriggerHelper(String pUserProfileName){

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        OpportunityTeamMemberTriggerHelper newHelper = new OpportunityTeamMemberTriggerHelper(pUserProfileName);
        return newHelper;
    }

/*
** @author : Cloud Sherpas Inc.
** @date : 03/20/2014
** @description : static method that instantiates a new instance of the class
** @paramaters : nothing
** @returns : a new instance of the OpportunityTeamMemberTriggerHelper class
*/
    public static OpportunityTeamMemberTriggerHelper NewTriggerHelper(){

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        OpportunityTeamMemberTriggerHelper newHelper = new OpportunityTeamMemberTriggerHelper('');
        return newHelper;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/20/2014
** @description : this method is the class constructor
** @paramaters : String user profile name
** @returns : nothing
*/
    private OpportunityTeamMemberTriggerHelper(String pUserProfileName){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','OpportunityTeamMemberTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        UserProfileName = pUserProfileName;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 03/31/2014
** @description : createCustomOpportunityTeamMembers
** @paramaters : list of OpportunityTeamMember
** @returns : none
*/
    public void createStandardOpportunityTeamMembers(list<OpportunityTeamMember__c> pOpportunityTeamMember){
        final string METHODNAME = CLASSNAME.replace('METHODNAME', 'createStandardOpportunityTeamMembers');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        list<OpportunityTeamMember> OpportunityTeamMemberToInsertList = new list<OpportunityTeamMember>();
        map<Id,OpportunityTeamMember__c> userIdToCustomOpportunityTeamMemberMap = new map<Id,OpportunityTeamMember__c>();
        list<Opportunity> opportunityToUpdate = new list<Opportunity>();
        map<id,Opportunity> opportunityidOpportunitysobjectmap = new map<id,Opportunity>();
        map<id,id> oppIdPrimaryUserIdMap = new   map<id,id> ();
        map<id,id> oppIdSecondaryUserIdMap = new   map<id,id> ();
        set<id> opportunityIds = new set<id>();

        for(OpportunityTeamMember__c oCustomOpportunityTeamMember : pOpportunityTeamMember){

            OpportunityTeamMember StandardOpportunityTeamMember = new OpportunityTeamMember();
            StandardOpportunityTeamMember.OpportunityId = oCustomOpportunityTeamMember.Opportunity__c;
            //StandardOpportunityTeamMember.OpportunityAccessLevel = oCustomOpportunityTeamMember.OpportunityAccess__c;
            StandardOpportunityTeamMember.UserId = oCustomOpportunityTeamMember.TeamMember__c;
            StandardOpportunityTeamMember.TeamMemberRole = oCustomOpportunityTeamMember.TeamRole__c;
           OpportunityTeamMemberToInsertList.add(StandardOpportunityTeamMember);
            userIdToCustomOpportunityTeamMemberMap.put(oCustomOpportunityTeamMember.TeamMember__c,oCustomOpportunityTeamMember);

            if(oCustomOpportunityTeamMember.TeamRole__c == 'Primary Sales Rep'){
                oppIdPrimaryUserIdMap.put(oCustomOpportunityTeamMember.Opportunity__c,oCustomOpportunityTeamMember.TeamMember__c);
            }
            if(oCustomOpportunityTeamMember.TeamRole__c == 'Secondary Sales Rep'){
                oppIdSecondaryUserIdMap.put(oCustomOpportunityTeamMember.Opportunity__c,oCustomOpportunityTeamMember.TeamMember__c);
            }
            opportunityIds.add(oCustomOpportunityTeamMember.Opportunity__c);
        }



        //try{
            if(!OpportunityTeamMemberToInsertList.isEmpty()){
                map<id, Opportunity> mapOpportunity = new map<id, Opportunity>([select id , OwnerId from opportunity where Id IN :opportunityIds]);
                CreateNewOpportunityShare(CreateNewOpportunityTeamMember(OpportunityTeamMemberToInsertList, userIdToCustomOpportunityTeamMemberMap, mapOpportunity));
            }
        /*}catch(Exception ex){
            throw BaseApplicationException.NewException(METHODNAME, ex.getMessage());
        }*/
    }

    private list<OpportunityShare> CreateNewOpportunityTeamMember(list<OpportunityTeamMember> pOpportunityTeamMemberToInsertList, map<Id,OpportunityTeamMember__c> pUserIdToCustomOpportunityTeamMemberMap , map<id, Opportunity> mapOpportunity){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateNewOpportunityTeamMember');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        list<OpportunityShare> opportunityShareToInsertList = new list<OpportunityShare>();

        Database.SaveResult[] teamMemberSaveResults = Database.insert(pOpportunityTeamMemberToInsertList,false);

        //insert any valid members then add their share entry if they were successfully added
        Integer newMemberCnt=0;

        for(Database.SaveResult saveResult : teamMemberSaveResults){
            if(!saveResult.isSuccess()){
                Database.Error saveResultErrorMessage =saveResult.getErrors()[0];
                system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nERROR ADDING TEAM MEMBER:'+ saveResultErrorMessage);
            }else{
                if(pUserIdToCustomOpportunityTeamMemberMap!= NULL){
                    if(!pUserIdToCustomOpportunityTeamMemberMap.IsEmpty()){
                        if(pUserIdToCustomOpportunityTeamMemberMap.containsKey(pOpportunityTeamMemberToInsertList[newMemberCnt].UserId)){
                            system.debug('>>>>>>>>>>>>'+mapOpportunity.get(pOpportunityTeamMemberToInsertList[newMemberCnt].Opportunityid).OwnerId+'>>>>>>>'+pOpportunityTeamMemberToInsertList[newMemberCnt].UserId );
                            //if(mapOpportunity.get(pOpportunityTeamMemberToInsertList[newMemberCnt].Opportunityid).OwnerId !=
                            //pOpportunityTeamMemberToInsertList[newMemberCnt].UserId ){
                            OpportunityShare OpportunitySharerule = new OpportunityShare();

                            OpportunitySharerule.UserOrGroupId=pOpportunityTeamMemberToInsertList[newMemberCnt].UserId;
                            OpportunitySharerule.OpportunityId=pOpportunityTeamMemberToInsertList[newMemberCnt].Opportunityid;
                            if(pUserIdToCustomOpportunityTeamMemberMap.get(pOpportunityTeamMemberToInsertList[newMemberCnt].UserId).OpportunityAccess__c == 'Read/Write'){
                                OpportunitySharerule.OpportunityAccessLevel='Edit';
                            }else if(pUserIdToCustomOpportunityTeamMemberMap.get(pOpportunityTeamMemberToInsertList[newMemberCnt].UserId).OpportunityAccess__c == 'Read Only'){
                                OpportunitySharerule.OpportunityAccessLevel='Read';
                            }
                            opportunityShareToInsertList.add(OpportunitySharerule);//}
                        }
                    }else{
                        if(mapOpportunity.get(pOpportunityTeamMemberToInsertList[newMemberCnt].Opportunityid).OwnerId !=pOpportunityTeamMemberToInsertList[newMemberCnt].UserId )
                            opportunityShareToInsertList.add(new OpportunityShare(UserOrGroupId=pOpportunityTeamMemberToInsertList[newMemberCnt].UserId, OpportunityId=pOpportunityTeamMemberToInsertList[newMemberCnt].Opportunityid, OpportunityAccessLevel='Edit'));
                    }
                }else{
                       if(mapOpportunity.get(pOpportunityTeamMemberToInsertList[newMemberCnt].Opportunityid).OwnerId !=pOpportunityTeamMemberToInsertList[newMemberCnt].UserId )
                            opportunityShareToInsertList.add(new OpportunityShare(UserOrGroupId=pOpportunityTeamMemberToInsertList[newMemberCnt].UserId, OpportunityId=pOpportunityTeamMemberToInsertList[newMemberCnt].Opportunityid, OpportunityAccessLevel='Edit'));
                }
            }
            newMemberCnt++;
        }

        return opportunityShareToInsertList;
    }

    /*
** @author : Cloud Sherpas, Inc.
** @date : 03/31/2014
** @description : ...
** @paramaters : OpportunityShare list
** @returns : nothing
*/
    private void CreateNewOpportunityShare(list<OpportunityShare> pOpportunityShareToInsertList){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','CreateNewOpportunityShare');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        system.debug('>>>>>>>>>>>>>>>>>>>>'+ pOpportunityShareToInsertList);
        Database.SaveResult[] sharingRuleSaveResult = Database.insert(pOpportunityShareToInsertList,false);

        //insert the new shares
        Integer newShareCnt = 0;

        for(Database.SaveResult saveResult: sharingRuleSaveResult){
            if(!saveResult.isSuccess()){
                Database.Error saveResultErrorMessage = saveResult.getErrors()[0];
                system.debug(LoggingLevel.DEBUG, METHODNAME + '\n\nERROR ADDING SHARING:'+ pOpportunityShareToInsertList[newShareCnt]+'::'+ saveResultErrorMessage);
            }
            newShareCnt++;
        }
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 04/01/2014
** @description : ...
** @paramaters : delete list
** @returns : nothing
*/
    public void deleteStandardOpportunityTeamMembers(list<OpportunityTeamMember__c> pOpportunityTeamMembers){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','deleteStandardOpportunityTeamMembers');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        list<opportunityteamMember> deletestandardOppTeamMembers = new list<opportunityteamMember>();
        set<id> userids = new set<id>();
        set<id> oppIds = new set<id>();
        Boolean SecondaryDeleted = false;
        list<Opportunity> updateOpportunity = new list<Opportunity>();

        list<OpportunityTeamMember__c> updateSecondaryOpportunityTeamMember = new list<OpportunityTeamMember__c>();
        for(OpportunityTeamMember__c oCustomOppTeamMember : pOpportunityTeamMembers){
            userids.add(oCustomOppTeamMember.TeamMember__c);
            oppIds.add(oCustomOppTeamMember.Opportunity__c);
            if(oCustomOppTeamMember.TeamRole__c == 'Sales Rep'){
                SecondaryDeleted = true;
            }
        }


        for(OpportunityTeamMember oStandardOpportunityTeamMember : [Select id,UserId,OpportunityId From OpportunityTeamMember WHERE UserId IN : userids AND OpportunityId IN: oppIds] ){
            deletestandardOppTeamMembers.add(oStandardOpportunityTeamMember );
        }

        if(!deletestandardOppTeamMembers.isEmpty()){
            //Jeff L. added as fix for I-180797 - need to check if there is an opportunity split that needs
            //to be deleted first
            List<OpportunitySplit> splitsToDelete = new List<OpportunitySplit>();

            for(OpportunitySplit os : [Select Id from OpportunitySplit  where SplitOwnerId in :userids]){
                splitsToDelete.add(os);
            }
            delete splitsToDelete;
            delete deletestandardOppTeamMembers;
            String msg = 'has been removed from Teaming Opportunity';
            //sendEmailToDeleteOppTeamMember(pOpportunityTeamMembers,msg);
        }

        if(SecondaryDeleted == true){
            for(Opportunity oOpportunity : [Select id,SecondarySalesRep__c, (Select id, TeamRole__c From Opportunity_Team_Members__r WHERE TeamRole__c =: 'Sales Rep' ORDER BY CreatedDate ASC ) FROM Opportunity Where Id IN: oppIds ]){

               if(userids.contains(oOpportunity.SecondarySalesRep__c)){

                   System.debug('Deleting SecondarySalesRep__c ' + oOpportunity.SecondarySalesRep__c + ' for opportunity ' + oOpportunity.Id);
                   oOpportunity.SecondarySalesRep__c = null;
                   updateOpportunity.add(oOpportunity);
               }

            }

            update updateOpportunity;
        }



    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 04/01/2014
** @description : ...
** @paramaters : Syncronize Custom OpportunityTeam with Standard Opportunity Team on Update.
** @returns : nothing
 */

    public void synchronizeCustomOppTeamMembersWithStandardOppTeamMembers(list<OpportunityTeamMember__c> pOpportunityTeamMembers){

        final string METHODNAME = CLASSNAME.replace('METHODNAME','synchronizeCustomOppTeamMembersWithStandardOppTeamMembers');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
     /*
        set<id> opportunityIds = new set<id>();
        map<id,OpportunityTeamMember__c> userIdCustOpportunityTeamMembermap = new map<id,OpportunityTeamMember__c>();
        map<id,OpportunityTeamMember> userIdStandardOpportunityTeamMembermap = new map<id,OpportunityTeamMember>();
        list<OpportunityTeamMember> updateStandardTeamMembers = new list<OpportunityTeamMember>();

        for(OpportunityTeamMember__c oOpportunityTeamMember: pOpportunityTeamMembers){
            opportunityIds.add(oOpportunityTeamMember.Opportunity__c);
            userIdCustOpportunityTeamMembermap.put(oOpportunityTeamMember.TeamMember__c, oOpportunityTeamMember);
        }

        for(OpportunityTeamMember oOpportunityTeamMember: [Select id,UserId,OpportunityId FROM OpportunityTeamMember  WHERE OpportunityId IN: opportunityIds ]){
            userIdStandardOpportunityTeamMembermap.put(oOpportunityTeamMember.UserId, oOpportunityTeamMember);
        }

        for(OpportunityTeamMember__c oOpportunityTeamMember: pOpportunityTeamMembers){
            if(!userIdStandardOpportunityTeamMembermap.isEmpty()){
                if(userIdStandardOpportunityTeamMembermap.containskey(oOpportunityTeamMember.TeamMember__c)){
                    userIdStandardOpportunityTeamMembermap.get(oOpportunityTeamMember.TeamMember__c).TeamMemberRole = oOpportunityTeamMember.TeamRole__c;
                    updateStandardTeamMembers.add(userIdStandardOpportunityTeamMembermap.get(oOpportunityTeamMember.TeamMember__c));
                }
            }
        }

        if(!updateStandardTeamMembers.isEmpty()){
            update updateStandardTeamMembers;
        }
*/
    }


/*
** @author : Cloud Sherpas, Inc.
** @date : 04/01/2014
** @description : ...
** @paramaters : Validate Insertion on Accountteammember__c
** @returns : nothing
 */

/*
** @author : Piyush Jain - Appirio
** @date : 21/07/2015
** @description : Commenting validateOpportunityTeamMemberInsertion as it is previously commented from handler class in onBeforeInsert
 */

/* public void validateOpportunityTeamMemberInsertion(list<OpportunityTeamMember__c> pOpportunityTeamMembers){
        set<id> opportunityIds = new set<id>();
        map<id,OpportunityTeamMember__c> userIdCustOpportunityTeamMembermap = new map<id,OpportunityTeamMember__c>();
        map<id,OpportunityTeamMember> userIdStandardOpportunityTeamMembermap = new map<id,OpportunityTeamMember>();
        list<OpportunityTeamMember> updateStandardTeamMembers = new list<OpportunityTeamMember>();
        for(OpportunityTeamMember__c oOpportunityTeamMember: pOpportunityTeamMembers){
            opportunityIds.add(oOpportunityTeamMember.Opportunity__c);
            userIdCustOpportunityTeamMembermap.put(oOpportunityTeamMember.TeamMember__c, oOpportunityTeamMember);
        }

        for(OpportunityTeamMember oOpportunityTeamMember: [Select id,UserId,OpportunityId FROM OpportunityTeamMember  WHERE OpportunityId IN: opportunityIds ]){
            userIdStandardOpportunityTeamMembermap.put(oOpportunityTeamMember.UserId, oOpportunityTeamMember);
        }

        for(OpportunityTeamMember__c oOpportunityTeamMember: pOpportunityTeamMembers){
            if(!userIdStandardOpportunityTeamMembermap.isEmpty()){
                if(userIdStandardOpportunityTeamMembermap.containskey(oOpportunityTeamMember.TeamMember__c)){
                   oOpportunityTeamMember.addError('Opportunity Team Member Already Exist');
                }
            }
        }
    } */

/*
** @author : Apttus
** @date : 29/10/2015
** @description : ...
** @paramaters : Validate Insertion on Accountteammember__c
** @returns : nothing
 */

    public void removeSameTeamMember(list<OpportunityTeamMember__c> pOpportunityTeamMembers){
        set<id> opportunityIds = new set<id>();
        map<id,OpportunityTeamMember__c> userIdCustOpportunityTeamMembermap = new map<id,OpportunityTeamMember__c>();
        //map<id,OpportunityTeamMember> userIdStandardOpportunityTeamMembermap = new map<id,OpportunityTeamMember>();
        list<OpportunityTeamMember__c> updateStandardTeamMembers = new list<OpportunityTeamMember__c>();

        for(OpportunityTeamMember__c oOpportunityTeamMember: pOpportunityTeamMembers){
            opportunityIds.add(oOpportunityTeamMember.Opportunity__c);
        }
        list<Opportunity> opportunityList =[SELECT ID FROM Opportunity WHERE Id in: opportunityIds ];
        updateStandardTeamMembers  = [Select id,TeamMember__c,Opportunity__c,TeamRole__c FROM OpportunityTeamMember__c  WHERE Opportunity__c IN: opportunityIds ];

        list<OpportunityTeamMember__c> toBeRemove = new list<OpportunityTeamMember__c>();
        for(Opportunity o : opportunityList ){
            map<id,OpportunityTeamMember__c> checkTeamMember = new map<id,OpportunityTeamMember__c>();
            for(OpportunityTeamMember__c oOpportunityTeamMember : updateStandardTeamMembers){
                if(o.Id == oOpportunityTeamMember.Opportunity__c){
                    if(checkTeamMember.containsKey(oOpportunityTeamMember.TeamMember__c)) {
                        toBeRemove.add(oOpportunityTeamMember);
                    } else {
                        checkTeamMember.put(oOpportunityTeamMember.TeamMember__c, oOpportunityTeamMember);
                    }
                }
            }
        }
        if(!toBeRemove.isEmpty()){
        OpportunityTeamMemberTriggerHandler.PreventRecursion = true;
            delete toBeRemove;
        }
    }

    public void UpdateoppSalesRepOndelete(list<OpportunityTeamMember> TeamList)
    {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','UpdateoppSalesRepOndelete');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        //JFreese Appirio S-435483 4/10/17 Check if we are in TABatchOpportunityQueueable & bypassing custom VRs
        Boolean bypassValidationRules = false;
        if(TABatchOpportunityQueueable.bypassOpportunityValidationRules != null){
            bypassValidationRules = TABatchOpportunityQueueable.bypassOpportunityValidationRules;
        }
        system.debug('^^^bypassValidationRules = '+bypassValidationRules);

        Set<id> OppSet  = new set<id>();
        for(OpportunityTeamMember Otemp : TeamList)
        {
           OppSet.add(otemp.OpportunityId);
        }
        MAP<id,Opportunity> OppMAP = new MAP<id,Opportunity>
                                            ([select id,SecondarySalesRep__c,
                                              Bypass_All_Validation_Rules__c  FROM Opportunity where id =:OppSet]);

         for(OpportunityTeamMember Otemp : TeamList)
        {
            If(OppMAP.get(otemp.OpportunityId).SecondarySalesRep__c!=null && Otemp.UserId == OppMAP.get(otemp.OpportunityId).SecondarySalesRep__c )
            {
                System.debug('Deleting SecondarySalesRep__c ' + Otemp.UserId + ' for opportunity ' + OppMAP.get(otemp.OpportunityId));
                OppMAP.get(otemp.OpportunityId).SecondarySalesRep__c = null;
            }

            //JFreese Appirio S-435483 4/10/17
            //If the OTMs are being deleted by TABatchOpportunityQueueable and it is bypassing VRs, then bypass them here too
            if (bypassValidationRules){
                 OppMAP.get(otemp.OpportunityId).Bypass_All_Validation_Rules__c = true;
            }
        }
        Update OppMAP.values();

    }
/*
** @author : Cloud Sherpas, Inc.
** @date : 04/01/2014
** @description : ...
** @paramaters : Send Email on delete of Standard Opportunity team member
** @returns : nothing
 */
   /*public void sendEmailStandardOppTeamMember(list<OpportunityTeamMember> pOpportunityTeamMembers, String msg){
    //HM - added msg parameter and use in this method per sprinter story #3885
    //HM - also changed 'pOpportunityTeamMember' parameter name to 'pOpportunityTeamMembers'
        // Send an email

        if(!pOpportunityTeamMembers.isEmpty()){
            String message = '';
            message = msg;



            set<id> OpportunityIdSet = new set<id>();
            set<id> UserIdSet = new set<id>();
            list<Messaging.SingleEmailMessage> mails = new list<Messaging.SingleEmailMessage>();

            for(OpportunityTeamMember oOpportunityTeamMember : pOpportunityTeamMembers){
                OpportunityIdSet.add(oOpportunityTeamMember.OpportunityId);
                UserIdSet.add(oOpportunityTeamMember.UserId);
            }

            map<id,User> UserIdSobjectMap = new map<id,User>([SELECT id,Name FROM User WHERE id IN: UserIdSet]);
            map<id,Opportunity> opportunityIdSobjectMap = new map<id,Opportunity>([SELECT id,Name,Link__c,Apttus_Approval__Approval_Status__c FROM Opportunity WHERE id IN: OpportunityIdSet]);

            for(OpportunityTeamMember oOpportunityTeamMember: pOpportunityTeamMembers){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(oOpportunityTeamMember.UserId);
                mail.setSubject(UserIdSobjectMap.get(oOpportunityTeamMember.UserId).Name + ' ' + message + ' :' + opportunityIdSobjectMap.get(oOpportunityTeamMember.OpportunityId).Name);
                mail.setsaveAsActivity(false);
                mail.setPlainTextBody(UserIdSobjectMap.get(oOpportunityTeamMember.UserId).Name + ' ' + message + '. The Approval Status for this Teaming Opportunity is ' + opportunityIdSobjectMap.get(oOpportunityTeamMember.OpportunityId).Apttus_Approval__Approval_Status__c + '. To Team on this opportunity, you will need to update and resubmit for approvals. If you feel this was done in error, please update accordingly.\r\n\r\n' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunityIdSobjectMap.get(oOpportunityTeamMember.OpportunityId).Id);
                mails.add(mail);
            }
            Messaging.sendEmail(mails);
        }
    }
    */
       // Commented out due to T-444892
   /* public void sendEmailToDeleteOppTeamMember(list<OpportunityTeamMember__c> teamMemebersToProcess, String msg){
    //HM - added msg parameter and use in this method per sprinter story #3885
    //HM - also changed 'pOpportunityTeamMember' parameter name to 'pOpportunityTeamMembers'
        // Send an email

        List<OpportunityTeamMember__c> pOpportunityTeamMembers = new List<OpportunityTeamMember__c>();
        for(OpportunityTeamMember__c member : teamMemebersToProcess){
             if(!member.System_Generated__c) {
                pOpportunityTeamMembers.add(member);
             }
        }

        if(!pOpportunityTeamMembers.isEmpty()){
            String message = '';
            message = msg;



            set<id> OpportunityIdSet = new set<id>();
            set<id> UserIdSet = new set<id>();
            list<Messaging.SingleEmailMessage> mails = new list<Messaging.SingleEmailMessage>();

            for(OpportunityTeamMember__c oOpportunityTeamMember : pOpportunityTeamMembers){
                OpportunityIdSet.add(oOpportunityTeamMember.Opportunity__c);
                UserIdSet.add(oOpportunityTeamMember.TeamMember__c);
            }

            map<id,User> UserIdSobjectMap = new map<id,User>([SELECT id,Name FROM User WHERE id IN: UserIdSet]);
            map<id,Opportunity> opportunityIdSobjectMap = new map<id,Opportunity>([SELECT id,Name,Link__c,Apttus_Approval__Approval_Status__c FROM Opportunity WHERE id IN: OpportunityIdSet]);

            for(OpportunityTeamMember__c oOpportunityTeamMember: pOpportunityTeamMembers){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(oOpportunityTeamMember.TeamMember__c);
                mail.setSubject(UserIdSobjectMap.get(oOpportunityTeamMember.TeamMember__c).Name + ' ' + message + ' :' + opportunityIdSobjectMap.get(oOpportunityTeamMember.Opportunity__c).Name);
                mail.setsaveAsActivity(false);
                mail.setPlainTextBody(UserIdSobjectMap.get(oOpportunityTeamMember.TeamMember__c).Name + ' ' + message + '. The Approval Status for this Teaming Opportunity is ' + opportunityIdSobjectMap.get(oOpportunityTeamMember.Opportunity__c).Apttus_Approval__Approval_Status__c + '. To Team on this opportunity, you will need to update and resubmit for approvals. If you feel this was done in error, please update accordingly.\r\n\r\n' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunityIdSobjectMap.get(oOpportunityTeamMember.Opportunity__c).Id);
                mails.add(mail);
            }
            Messaging.sendEmail(mails);
        }
    }


/*
** @author : Cloud Sherpas, Inc.
** @date : 04/24/2014
** @description : ...
** @paramaters : Validation Rule to delete Opportunity Team Member
** @returns : nothing
 */
/*
** @author : Piyush Jain - Appirio
** @date : 21/07/2015
** @description : Commenting ValidationToAvoidDeletionOfPrimarySalesRep as it is previously commented from handler class in onBeforeDelete
*/

/* public void ValidationToAvoidDeletionOfPrimarySalesRep(list<OpportunityTeamMember__c> pOpportunityTeamMembers){
        set<id> OpportunityTeamMemberidSet = new set<id>();
        set<id> OpportunityTeamMemberidErroredSet = new set<id>();
        // Send an email
        if(!pOpportunityTeamMembers.isEmpty()){
            for(OpportunityTeamMember__c oOpportunityTeamMember : pOpportunityTeamMembers){
                OpportunityTeamMemberidSet.add(oOpportunityTeamMember.id);
            }

            for(OpportunityTeamMember__c oOpportunityTeamMember : [SELECT id,TeamMember__c,Opportunity__r.OwnerId FROM OpportunityTeamMember__c WHERE id IN: OpportunityTeamMemberidSet]){
                if(oOpportunityTeamMember.Opportunity__r.OwnerId == oOpportunityTeamMember.TeamMember__c){
                    OpportunityTeamMemberidErroredSet.add(oOpportunityTeamMember.id);
                }
            }

            for(OpportunityTeamMember__c oOpportunityTeamMember : pOpportunityTeamMembers){
                if(OpportunityTeamMemberidErroredSet.contains(oOpportunityTeamMember.id)){
                    oOpportunityTeamMember.addError('Cannot Delete the Primary Sales Rep');
                }
            }

        }

    } */

    /*
** @author : Cloud Sherpas, Inc.
** @date : 07/18/2014
** @description : Set the Teaming Scenario and Teaming type.
** @Story : 0924
** @Element : E1814
** @paramaters : List of Opportunity Team Members
** @returns : nothing
 */
    // Commented out due to T-444890
   /* public void SetTeamingScenarioAndType(list<OpportunityTeamMember> pOpportunityTeamMembers){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','SetTeamingScenarioAndType');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        set<id> OpportunityIdAllSalesRepList = new set<id>();
        set<id> AccountIdList = new set<id>();
        set<id> UserList = new set<id>();
        set<id> AtmUser = new set<id>();
        set<id> SecondaryUserList = new set<id>();
        map<Id, Account> accMap= new map<Id, Account>();

        boolean allOppoSalesRepInAccountSalesRep = false;
        boolean allOppoTeamMemberNotUserPartner = false;
        Boolean doIt = false;
        Boolean emptyUserTeamChannel = false;
        map<Id, User> SecUserMap= new map<Id, User>();
        map<Id, User> userMap= new map<Id, User>();
        map<Id, Account> AccountMap= new map<Id, Account>();
        try {
            for(OpportunityTeamMember oOpportunityTeamMember : pOpportunityTeamMembers){
                if(oOpportunityTeamMember.TeamMemberRole == 'Sales Rep' || oOpportunityTeamMember.TeamMemberRole == 'Primary Sales Rep'){
                    OpportunityIdAllSalesRepList.add(oOpportunityTeamMember.Opportunityid);
                }
            }
            if(!OpportunityIdAllSalesRepList.isEmpty()){
                List<Opportunity> oppoList = [SELECT Id, Apttus_Approval__Approval_Status__c,
                                                            TeamingScenario__c,
                                                            TeamingType__c,
                                                            RejectionReason__c,
                                                            OwnerId,
                                                            SecondarySalesRep__c,
                                                            AccountId,
                                                            CloseDate
                                                    FROM Opportunity WHERE Id IN : OpportunityIdAllSalesRepList];
                for(Opportunity op : oppoList){
                    AccountIdList.add(op.AccountId);
                    UserList.add(op.OwnerId);
                    if(op.SecondarySalesRep__c != null){
                        SecondaryUserList.add(op.SecondarySalesRep__c);
                    }
                }

                if(!SecondaryUserList.isEmpty()){
                    List<User> suList = [SELECT Id, TeamingChannel__c, Country FROM User WHERE Id IN : SecondaryUserList];

                    if(!suList.isEmpty()){
                        for(User su : suList){
                            SecUserMap.put(su.Id, su);
                        }
                    }
                }

                if(!UserList.isEmpty()){
                    List<User> uList = [SELECT Id,TeamingChannel__c, Country FROM User WHERE Id IN : UserList];

                    if(!uList.isEmpty()){
                        for(User u : uList){
                            userMap.put(u.Id, u);
                        }
                    }
                }

                if(!AccountIdList.isEmpty()){
                    List<Account> accList = [SELECT Id, NewspaperStatus__c, AccountStatus__c,
                                                    SalesChannel__c, MasterHQ__c, AccountGroup__c,
                                                    CustomerDate__c, CustomerLapsedDate__c, AccountTeam__c
                                                FROM Account WHERE Id IN : AccountIdList];

                    Integer accountCount = 0;
                    for(Account acc : accList){
                        AccountMap.put(acc.Id, acc);
                    }
                }
                List<OpportunityTeamMember> allUserIdInOTM = [SELECT UserId FROM OPPORTUNITYTEAMMEMBER WHERE OpportunityId IN : OpportunityIdAllSalesRepList];
                set<Id> allUserId = new set<Id>();
                if(!allUserIdInOTM.isEmpty()){
                    for(OpportunityTeamMember otm : allUserIdInOTM){
                        allUserId.add(otm.UserId);
                    }

                    if(!allUserId.isEmpty()){
                        List<User> allUserTC = [SELECT TeamingChannel__c FROM User WHERE Id IN : allUserId];
                        Integer count = 0;
                        if(!allUserTC.isEmpty()){
                            for(User u : allUserTC){
                                if(u.TeamingChannel__c == 'Partner'){
                                    count++;
                                }
                            }
                            if(count > 0){
                                allOppoTeamMemberNotUserPartner = false;
                            } else {
                                allOppoTeamMemberNotUserPartner = true;
                            }
                            emptyUserTeamChannel = true;
                        } else {
                            emptyUserTeamChannel = false;
                        }
                        if(emptyUserTeamChannel){
                            List<AccountTeamMember> allUserIdInATM = [SELECT UserId FROM ACCOUNTTEAMMEMBER WHERE AccountId in : AccountIdList AND UserID IN : allUserId];
                            if(allUserIdInOTM.size() == allUserIdInATM.size()){
                                allOppoSalesRepInAccountSalesRep = true;
                            } else {
                                allOppoSalesRepInAccountSalesRep = false;
                            }
                        }
                        if(allUserIdInOTM.size() > 1){
                            doIt = true;
                        }
                    }
                }
                List<Opportunity> oppoToBeUpdate = new List<Opportunity>();
                Boolean isNamed = false;
                if(doIt){
                    for(Opportunity o : oppoList){
                        if((o.Apttus_Approval__Approval_Status__c == 'No Approval Needed' || o.Apttus_Approval__Approval_Status__c == 'Not Submitted' || o.Apttus_Approval__Approval_Status__c == 'Pending Approval')
                            || ((o.Apttus_Approval__Approval_Status__c == 'Rejected') && (o.RejectionReason__c == 'Minimum Threshold Not Met'
                            || (o.RejectionReason__c == 'Opportunity Team Change' || o.RejectionReason__c == 'Rep Requested Recall')))){

                            if(o.TeamingScenario__c == 'Named' || o.TeamingScenario__c == 'International Named'){
                                isNamed = true;
                            }
                            if(o.OwnerId!=null && o.SecondarySalesRep__c!= null && o.AccountId!=null){
                                if(userMap.get(o.OwnerId).Country == SecUserMap.get(o.SecondarySalesRep__c).Country && ((allOppoSalesRepInAccountSalesRep && AccountMap.get(o.AccountId).MasterHQ__c == false)
                                    || (allOppoSalesRepInAccountSalesRep && AccountMap.get(o.AccountId).MasterHQ__c == true && AccountMap.get(o.AccountId).AccountGroup__c != 'Distributed Selling'))){
                                    o.TeamingScenario__c = 'Named';
                                    o.Apttus_Approval__Approval_Status__c = 'No Approval Needed';
                                } else if(!allOppoSalesRepInAccountSalesRep && SecUserMap.get(o.SecondarySalesRep__c).TeamingChannel__c != 'Partner' && (userMap.get(o.OwnerId).TeamingChannel__c == 'Telesales' || userMap.get(o.OwnerId).TeamingChannel__c == 'Fieldsales')
                                    && userMap.get(o.OwnerId).Country == SecUserMap.get(o.SecondarySalesRep__c).Country){
                                    o.TeamingScenario__c = 'Ad Hoc';
                                } else if(!allOppoSalesRepInAccountSalesRep && (userMap.get(o.OwnerId).TeamingChannel__c == 'Partner' || SecUserMap.get(o.SecondarySalesRep__c).TeamingChannel__c == 'Partner')&& (userMap.get(o.OwnerId).Country == SecUserMap.get(o.SecondarySalesRep__c).Country)){
                                    o.TeamingScenario__c = 'Newspaper';
                                } else if(!allOppoSalesRepInAccountSalesRep && SecUserMap.get(o.SecondarySalesRep__c).TeamingChannel__c != 'Partner' && (userMap.get(o.OwnerId).TeamingChannel__c == 'Telesales' || userMap.get(o.OwnerId).TeamingChannel__c == 'Fieldsales')
                                    && userMap.get(o.OwnerId).Country != SecUserMap.get(o.SecondarySalesRep__c).Country){
                                    o.TeamingScenario__c = 'International';
                                } else if(!allOppoSalesRepInAccountSalesRep && ((userMap.get(o.OwnerId).TeamingChannel__c == 'Partner' || SecUserMap.get(o.SecondarySalesRep__c).TeamingChannel__c == 'Partner')
                                    && (userMap.get(o.OwnerId).Country != SecUserMap.get(o.SecondarySalesRep__c).Country))){
                                    o.TeamingScenario__c = 'International Newspaper';
                                } else if((userMap.get(o.OwnerId).Country != SecUserMap.get(o.SecondarySalesRep__c).Country && allOppoSalesRepInAccountSalesRep && AccountMap.get(o.AccountId).MasterHQ__c == false)
                                    || (userMap.get(o.OwnerId).Country != SecUserMap.get(o.SecondarySalesRep__c).Country && allOppoSalesRepInAccountSalesRep && AccountMap.get(o.AccountId).MasterHQ__c == true && AccountMap.get(o.AccountId).AccountGroup__c != 'Distributed Selling')){
                                    o.TeamingScenario__c = 'International Named';
                                    o.Apttus_Approval__Approval_Status__c = 'No Approval Needed';
                                } else {
                                    o.TeamingScenario__c = null;
                                }

                                if(isNamed && (o.TeamingScenario__c != 'Named' && o.TeamingScenario__c != 'International Named')){
                                    o.Apttus_Approval__Approval_Status__c = 'Not Submitted';
                                } else if((o.TeamingScenario__c != 'Named' && o.TeamingScenario__c != 'International Named') && (o.Apttus_Approval__Approval_Status__c == 'Pending Approval' || o.Apttus_Approval__Approval_Status__c == 'Approved')){
                                    o.Apttus_Approval__Approval_Status__c = 'Rejected';
                                    o.RejectionReason__c = 'Opportunity Team Change';
                                }
                            }
                            //Set the Teaming Type
                            if(o.AccountId!= null){
                                if(allOppoTeamMemberNotUserPartner && AccountMap.get(o.AccountId).AccountStatus__c == 'Candidate'
                                    && !allOppoSalesRepInAccountSalesRep && AccountMap.get(o.AccountId).CustomerDate__c == null
                                    && AccountMap.get(o.AccountId).NewspaperStatus__c != 'Partner Exclusive'){
                                    o.TeamingType__c = 'New';
                                } else if((!allOppoTeamMemberNotUserPartner && AccountMap.get(o.AccountId).AccountStatus__c == 'Candidate' && !allOppoSalesRepInAccountSalesRep)
                                    || (!allOppoTeamMemberNotUserPartner && AccountMap.get(o.AccountId).AccountStatus__c == 'Lapsed Customer' && !allOppoSalesRepInAccountSalesRep && AccountMap.get(o.AccountId).SalesChannel__c == 'Partner'
                                    && AccountMap.get(o.AccountId).CustomerLapsedDate__c + 90 < o.CloseDate)
                                    || (!allOppoTeamMemberNotUserPartner && AccountMap.get(o.AccountId).AccountStatus__c == 'Lapsed Customer' && !allOppoSalesRepInAccountSalesRep && AccountMap.get(o.AccountId).SalesChannel__c == 'Partner.hj'
                                    && AccountMap.get(o.AccountId).CustomerLapsedDate__c + 180 < o.CloseDate)) {
                                    o.TeamingType__c = 'New/Winback';
                                } else if((allOppoSalesRepInAccountSalesRep && allOppoTeamMemberNotUserPartner && AccountMap.get(o.AccountId).MasterHQ__c == false)
                                    || (allOppoSalesRepInAccountSalesRep && allOppoTeamMemberNotUserPartner && AccountMap.get(o.AccountId).MasterHQ__c == true && AccountMap.get(o.AccountId).AccountGroup__c != 'Distributed Selling')){
                                    o.TeamingType__c = 'Named';
                                } else if(allOppoTeamMemberNotUserPartner && AccountMap.get(o.AccountId).AccountStatus__c == 'Lapsed Customer' && !allOppoSalesRepInAccountSalesRep && AccountMap.get(o.AccountId).CustomerLapsedDate__c + 365 < o.CloseDate
                                    && AccountMap.get(o.AccountId).NewspaperStatus__c != 'Partner Exclusive'){
                                    o.TeamingType__c = 'Winback';
                                } else if((!allOppoSalesRepInAccountSalesRep && !allOppoTeamMemberNotUserPartner && AccountMap.get(o.AccountId).AccountStatus__c == 'Customer')
                                    || (!allOppoSalesRepInAccountSalesRep && !allOppoTeamMemberNotUserPartner && AccountMap.get(o.AccountId).AccountStatus__c == 'Lapsed Customer' && AccountMap.get(o.AccountId).CustomerLapsedDate__c + 90 >= o.CloseDate && AccountMap.get(o.AccountId).SalesChannel__c == 'Partner')
                                    || (!allOppoSalesRepInAccountSalesRep && !allOppoTeamMemberNotUserPartner && AccountMap.get(o.AccountId).AccountStatus__c == 'Lapsed Customer' && AccountMap.get(o.AccountId).CustomerLapsedDate__c + 180 >= o.CloseDate && AccountMap.get(o.AccountId).SalesChannel__c == 'Partner.hj')
                                    || ((AccountMap.get(o.AccountId).AccountStatus__c != 'Candidate' || AccountMap.get(o.AccountId).AccountStatus__c == 'Lapsed Customer') && !allOppoSalesRepInAccountSalesRep)
                                    || (allOppoTeamMemberNotUserPartner && AccountMap.get(o.AccountId).AccountStatus__c == 'Candidate' && !allOppoSalesRepInAccountSalesRep && AccountMap.get(o.AccountId).NewspaperStatus__c == 'Partner Exclusive')
                                    || (allOppoTeamMemberNotUserPartner && AccountMap.get(o.AccountId).AccountStatus__c == 'Candidate' && !allOppoSalesRepInAccountSalesRep && AccountMap.get(o.AccountId).CustomerDate__c != null)
                                    || (allOppoTeamMemberNotUserPartner && AccountMap.get(o.AccountId).AccountStatus__c == 'Lapsed Customer' && !allOppoSalesRepInAccountSalesRep && AccountMap.get(o.AccountId).CustomerLapsedDate__c + 365 >= o.CloseDate && AccountMap.get(o.AccountId).NewspaperStatus__c != 'Partner Exclusive')
                                    || (!allOppoTeamMemberNotUserPartner && allOppoSalesRepInAccountSalesRep)){
                                    o.TeamingType__c = 'Renewal/Existing Customer';
                                } else if(allOppoSalesRepInAccountSalesRep && allOppoTeamMemberNotUserPartner
                                    && AccountMap.get(o.AccountId).MasterHQ__c == true && AccountMap.get(o.AccountId).AccountGroup__c == 'Distributed Selling'){
                                    o.TeamingType__c = null;
                                }
                            }
                            system.debug('<<<teamingtype'+ o.TeamingType__c);
                            system.debug('<<<teamingscenario'+ o.TeamingScenario__c);
                            oppoToBeUpdate.add(o);
                        }
                    }

                    if(oppoToBeUpdate.size() > 0){
                        OpportunityTriggerHandler.PreventRecursion = true;
                        update oppoToBeUpdate;
                    }
                }
            }
        }catch(DMLException e){
            ExceptionLog.add('DMLException', 'OpportunityTeamMemberTriggerHelper', 'SetTeamingScenarioAndType', e.getMessage());
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME,'Failed to update opportunity.' ,e);
        }
    } */
}