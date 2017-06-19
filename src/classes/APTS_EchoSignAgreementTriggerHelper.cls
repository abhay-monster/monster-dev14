public with sharing class APTS_EchoSignAgreementTriggerHelper {
    final String CLASSNAME = '\n\n**** APTS_EchoSignAgreementTriggerHelper.METHODNAME()';
    static integer Total = 5;
    public Org_Settings__c orgSettings = Org_Settings__c.getInstance();




                                        private String UserProfileName{get; private set;}

    private map<Id, User> UserIdToUserMap {
        get{
            if(UserIdToUserMap == NULL){
                UserIdToUserMap = new map<Id,User>([SELECT Id, ManagerId FROM User]);
            }
            return UserIdToUserMap;
        }
        private set;
    }

    /*
** @author : Ranjeet, Apttus Inc.
** @date : 11/05/2014
** @description :
** @paramaters :
** @returns :
*/
    public static APTS_EchoSignAgreementTriggerHelper NewTriggerHelper(String pUserProfileName) {

        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        APTS_EchoSignAgreementTriggerHelper newHelper = new APTS_EchoSignAgreementTriggerHelper(pUserProfileName);
        return newHelper;
    }

    /*
** @author : Ranjeet, Apttus Inc.
** @date : 11/05/2014
** @description :
** @paramaters :
** @returns : nothing
*/
    private APTS_EchoSignAgreementTriggerHelper(String pUserProfileName) {

        final string METHODNAME = CLASSNAME.replace('METHODNAME','APTS_EchoSignAgreementTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        UserProfileName = pUserProfileName;
    }

    /*
** @author : Ranjeet, Apttus Inc.
** @date : 11/05/2014
** @description :
** @paramaters :
** @returns :
*/
    public void setAccountAndOpportunity(echosign_dev1__SIGN_Agreement__c [] pEchoSignAgreementList) {
        Set<Id> apttusProposalIdSet = new Set<Id>();

        for(echosign_dev1__SIGN_Agreement__c echosignAgreementObj : pEchoSignAgreementList) {
            apttusProposalIdSet.add(echosignAgreementObj.Apttus_QPESign__Apttus_Proposal__c);
        }

        if(apttusProposalIdSet.isEmpty()) {
            return;
        }

        Map<Id, Apttus_Proposal__Proposal__c> proposalMap = new Map<Id, Apttus_Proposal__Proposal__c>([Select Apttus_Proposal__Account__c, Apttus_Proposal__Opportunity__c
                                                                                                       From Apttus_Proposal__Proposal__c Where Id IN :apttusProposalIdSet]);

        for(echosign_dev1__SIGN_Agreement__c echosignAgreementObj : pEchoSignAgreementList) {
            Apttus_Proposal__Proposal__c proposal = proposalMap.get(echosignAgreementObj.Apttus_QPESign__Apttus_Proposal__c);

            if(proposal != null) {
                echosignAgreementObj.echosign_dev1__Account__c = proposal.Apttus_Proposal__Account__c;
                echosignAgreementObj.echosign_dev1__Opportunity__c = proposal.Apttus_Proposal__Opportunity__c;
            }
        }
    }

    /*
    ** @author : Sweety, Apttus Inc.
    ** @date : 9/9/2015
    ** @description : This mthod is used to add signers based on template name
    ** @paramaters :
    ** @returns :
    */
    public void setContacts(echosign_dev1__SIGN_Agreement__c [] pEchoSignAgreementList) {
        Set<Id> setProposalIds = new Set<Id>();
        Map<Id, Integer> mapAgrrIdToRecipients = new Map<Id, Integer>();
        Map<Id,Integer> mapProposalIdToSigners = new Map<Id, Integer>();
        //Map<Id, String> mapProposalIdToTemplateName = new Map<Id, String>();
        List<Attachment> lstAttachment = new List<Attachment>();


        //loop through the list and find all proposal ids
        for(echosign_dev1__SIGN_Agreement__c echosignAgreementObj : pEchoSignAgreementList) {
            setProposalIds.add(echosignAgreementObj.Apttus_QPESign__Apttus_Proposal__c);
        }

        //find all attched document of proposal
        lstAttachment = [Select id,Name,ParentId from Attachment where ParentId in :setProposalIds order by LastModifiedDate desc];

        List<Apttus_Proposal__Proposal__c> lstProposals = [Select id, Apttus_Proposal__Proposal_Name__c, Template_Name_And_Signers__c from Apttus_Proposal__Proposal__c where id in : setProposalIds];
        for(Apttus_Proposal__Proposal__c oProposal : lstProposals)
        {
            String strAttchName = '';
            Integer numOfSigners = 0;
            for(Attachment attach : lstAttachment)
            {
                strAttchName = attach.Name;
                if(strAttchName.contains(oProposal.Apttus_Proposal__Proposal_Name__c))
                {
                    //mapProposalIdToTemplateName.put(oProposal.Id, strAttchName);
                    break;
                }
            }
            if(oProposal.Template_Name_And_Signers__c != null)
            {
                String strTempNameAndSigners = oProposal.Template_Name_And_Signers__c;
				String[] splitList = strTempNameAndSigners.split(':');
                 System.debug('splitList'+splitList);
                for(integer iCount=0; iCount < splitList.size(); iCount++)
                {
                    String str = splitList[iCount];
                    System.debug('str'+str);
                    if(str != null)
                    {
                    	String[] splitOneLevel = str.split(',');

                        System.debug('splitOneLevel'+splitOneLevel);

                        if(splitOneLevel != null && strAttchName.contains(splitOneLevel[0]))
                        {
                            System.debug('splitOneLevel[1]'+splitOneLevel[1]);
                            if(splitOneLevel[1] != 'null')
                            	numOfSigners = Integer.ValueOf(splitOneLevel[1]);
                        }
                    }
                }

                /*for(string strSplit : splitList)
                { System.debug('**strSplit'+strSplit);
                    if(strAttchName.contains(strSplit[0]))
                    {
                         //System.debug('**sweety'+strSplit[0]);
                        //String[] splitOneLevel = strSplit.split(',');
                        //if(splitOneLevel.size() > 0)
                        	numOfSigners = Integer.ValueOf(strSplit[1]);
                    }
                }*/
                mapProposalIdToSigners.put(oProposal.Id, numOfSigners);
            }
            else
                mapProposalIdToSigners.put(oProposal.Id, 0);
        }

        /*
		for(Apttus_Proposal__Proposal__c oProposal : lstProposals)
        {
            if(oProposal.Template_Signers__c != null)
                mapProposalIdToSigners.put(oProposal.Id, (Integer)oProposal.Template_Signers__c);
            else
                mapProposalIdToSigners.put(oProposal.Id, 0);
        }*/

        List<echosign_dev1__SIGN_Recipients__c> lstRecipientsToUpdate = new List<echosign_dev1__SIGN_Recipients__c>();
        for(echosign_dev1__SIGN_Agreement__c echosignAgreementObj : pEchoSignAgreementList) {

            echosign_dev1__SIGN_Recipients__c oRecipient = new echosign_dev1__SIGN_Recipients__c();
            Integer iNeededCount = 0;
            if(mapProposalIdToSigners != null && mapProposalIdToSigners.get(echosignAgreementObj.Apttus_QPESign__Apttus_Proposal__c) != null)
                iNeededCount = mapProposalIdToSigners.get(echosignAgreementObj.Apttus_QPESign__Apttus_Proposal__c);
            Integer iAttachedReciCount = 0;

            if(echosignAgreementObj.echosign_dev1__Recipient__c != null)
            {
                iAttachedReciCount = 1;
                oRecipient.echosign_dev1__Agreement__c = echosignAgreementObj.id;
                oRecipient.echosign_dev1__Contact__c = echosignAgreementObj.echosign_dev1__Recipient__c;
                oRecipient.echosign_dev1__Order_Number__c = 1;
                oRecipient.echosign_dev1__Recipient_Type__c = 'Contact';
                lstRecipientsToUpdate.add(oRecipient);
            }

            if(iNeededCount != 0 && iNeededCount - iAttachedReciCount > 0)
            {
                Integer iDiff = iNeededCount - iAttachedReciCount;
                for(Integer i=0; i < iDiff; i++)
                {
                    oRecipient = new echosign_dev1__SIGN_Recipients__c();
                    oRecipient.echosign_dev1__Agreement__c = echosignAgreementObj.id;
                    oRecipient.echosign_dev1__Contact__c = null;
                    oRecipient.echosign_dev1__Order_Number__c = 1;
                    oRecipient.echosign_dev1__Recipient_Type__c = 'Contact';
                    lstRecipientsToUpdate.add(oRecipient);
                }
            }
        }
       insert lstRecipientsToUpdate;
    }


    /*
    public void CheckStatusChange(List<echosign_dev1__SIGN_Agreement__c> NewList , MAP<id,echosign_dev1__SIGN_Agreement__c> OldAgreementMAP )
    {
        for(echosign_dev1__SIGN_Agreement__c echosignAgreement : NewList)
        {
                echosign_dev1__SIGN_Agreement__c oTemp = OldAgreementMAP.get(echosignAgreement.id);

                if(echosignAgreement.echosign_dev1__Status__c != oTemp.echosign_dev1__Status__c)
                {
                    //System.debug(' New Status'+DaTeTime.now()+' '+ echosignAgreement.echosign_dev1__Status__c);
                    System.debug(' old Status'+DaTeTime.now()+' '+ oTemp.echosign_dev1__Status__c);
                }
        }


    }
*/
    /*
    public void setContactsOnEchosignAgreement(echosign_dev1__SIGN_Agreement__c [] pEchoSignAgreementList)
    {
        Set<ID> echosignQuoteIds = new Set<ID>();
        //System.debug(Trigger.New);
        Map<Id,List<Contact>> mapPropToPropContact = new Map<Id,List<Contact>>();
        Contact contact = new Contact();

        for(echosign_dev1__SIGN_Agreement__c echosignAgreement : pEchoSignAgreementList)
        {
            echosignQuoteIds.add(echosignAgreement.Apttus_QPESign__Apttus_Proposal__c);
        }
        //System.debug('echosignQuoteIds'+echosignQuoteIds);

        List<Apttus_Proposal__Proposal__c> lstProposals = new List<Apttus_Proposal__Proposal__c>();

        lstProposals = [Select id,Apttus_Proposal__Account__c from Apttus_Proposal__Proposal__c where id in :echosignQuoteIds];


        for(Apttus_Proposal__Proposal__c oProposal : lstProposals)
        {
            Id AccountID = oProposal.Apttus_Proposal__Account__c;
            List<Contact> lstContact = [Select id,Name from contact where accountid =:AccountID];

            if(lstContact.size() > 0)
                contact = lstContact[0];

            //System.debug('lstContact '+lstContact );
            mapPropToPropContact.put(oProposal.id, lstContact );
           // System.debug('mapPropToPropContact'+mapPropToPropContact);

        }

        for(echosign_dev1__SIGN_Agreement__c echosignAgreement : pEchoSignAgreementList)
        {
            List<Contact> lstContact = mapPropToPropContact.get(echosignAgreement.Apttus_QPESign__Apttus_Proposal__c);
            // echosignAgreement.Contacts__c = mapPropToPropContact.get(echosignAgreement.Apttus_QPESign__Apttus_Proposal__c).Name;
        }
    }*/

    public void setDefaultLanguague(List<echosign_dev1__SIGN_Agreement__c> NewList)
    {
        MAP<id,echosign_dev1__SIGN_Agreement__c> ProposalEchoSignMap = new MAP<id,echosign_dev1__SIGN_Agreement__c>();
        MAP<string,string> PropToEchoLangMAP = new MAP<string,string>();

        for(echosign_dev1__SIGN_Agreement__c OAgr : NewList)
        {
        	ProposalEchoSignMap.put(OAgr.Apttus_QPESign__Apttus_Proposal__c,OAgr);
        }
        for(Proposal_to_EchoSign_lang_Mapping__mdt OTemp: [select id,EchoSign_Proposal__c,Proposal_Languague__c
                                                           from Proposal_to_EchoSign_lang_Mapping__mdt])
        {
            PropToEchoLangMAP.put(OTemp.Proposal_Languague__c , Otemp.EchoSign_Proposal__c);
        }
        for(Apttus_Proposal__Proposal__c oProp: [select id,Language__c
                                           	FROm Apttus_Proposal__Proposal__c where id= :ProposalEchoSignMap.keySet() ])
        {
            If(String.isNotBlank(oProp.Language__c) &&  PropToEchoLangMAP.containsKey(oProp.Language__c))
            {
                ProposalEchoSignMap.get(oProp.id).echosign_dev1__AgreementLocale__c = PropToEchoLangMAP.get(oProp.Language__c);
            }
        }
    }
    public void setCCAddress(List<echosign_dev1__SIGN_Agreement__c> NewList , MAP<id,echosign_dev1__SIGN_Agreement__c> OldAgreementMAP ,string sCallFrom)
    {
        set<id> UserId = new set<id>();
        set<id> ContactId = new set<id>();
        MAP<id,User> UserMAP  = new MAP<id,User>();
        MAP<id,Contact> ContactMAP  = new MAP<id,Contact>();
        for(echosign_dev1__SIGN_Agreement__c echosignAgreement : NewList)
        {
            for(integer i=1 ; i<=Total ; i++)
            {
                If(echosignAgreement.get('Additional_CC_Contact'+i+'__c') != null)
                {
                    ContactId.add((id)echosignAgreement.get('Additional_CC_Contact'+i+'__c'));
                }

                If(echosignAgreement.get('Additional_CC_User'+i+'__c') != null)
                {
                    UserId.add((id)echosignAgreement.get('Additional_CC_User'+i+'__c'));
                }
            }

            If(sCallFrom != 'Insert')
            {
                If(OldAgreementMAP.containsKey(echosignAgreement.Id))
                {
                    echosign_dev1__SIGN_Agreement__c oTemp = OldAgreementMAP.get(echosignAgreement.id);

                    for(integer i=1 ; i<=Total ; i++)
                    {
                        If(oTemp.get('Additional_CC_Contact'+i+'__c') != null)
                        {
                            ContactId.add((id)oTemp.get('Additional_CC_Contact'+i+'__c'));
                        }

                        If(oTemp.get('Additional_CC_User'+i+'__c') != null)
                        {
                            UserId.add((id)oTemp.get('Additional_CC_User'+i+'__c'));
                        }
                    }
                }
            }

        }

        If(UserId.size() > 0 )
        {
            UserMAP = new MAP<id,User>([select id, email from user where id = :userId]);
        }
        If(ContactId.size() > 0)
        {
            ContactMAP = new MAP<id,Contact>([select id, email from Contact where id = :ContactId]);
        }

        for(echosign_dev1__SIGN_Agreement__c echosignAgreement : NewList)
        {
            string sCCEmail = echosignAgreement.echosign_dev1__Cc__c;
            If(string.isBlank(sCCEmail))
            {
                sCCEmail = '';
            }

            If(sCallFrom != 'Insert')
            {
                If(OldAgreementMAP.containsKey(echosignAgreement.Id))
                {
                    echosign_dev1__SIGN_Agreement__c oTemp = OldAgreementMAP.get(echosignAgreement.id);

                    for(integer i=1 ; i<=Total ; i++)
                    {
                        If(oTemp.get('Additional_CC_Contact'+i+'__c') != null)
                        {
                            Id TempId = (id) oTemp.get('Additional_CC_Contact'+i+'__c');
                            string sEmail  = ContactMAP.get(TempId).email;
                            If(String.isNotBlank(sEmail))
                            {
                                If(sCCEmail.containsIgnoreCase(sEmail))
                                {
                                    sCCEmail= sCCEmail.replace(sEmail, '');
                                }
                            }

                        }

                        If(oTemp.get('Additional_CC_User'+i+'__c') != null)
                        {

                            Id TempId = (id) oTemp.get('Additional_CC_User'+i+'__c');
                            string sEmail  = UserMAP.get(TempId).email;
                            If(String.isNotBlank(sEmail))
                            {
                                If(sCCEmail.containsIgnoreCase(sEmail))
                                {
                                    sCCEmail= sCCEmail.replace(sEmail, '');
                                }
                            }
                        }
                    }
                }
            }
            for(integer i=1 ; i<=Total ; i++)
            {
                If(echosignAgreement.get('Additional_CC_Contact'+i+'__c') != null)
                {
                    Id TempId = (id) echosignAgreement.get('Additional_CC_Contact'+i+'__c');
                    string sEmail  = ContactMAP.get(TempId).email;
                    If( string.isNotBlank(sEmail))
                    {
                        If(! sCCEmail.endsWith(',') &&  ! sCCEmail.endsWith(';') )
                        {
                            sCCEmail = sCCEmail + ';';
                        }

                        sCCEmail = sCCEmail +  sEmail;
                    }
                }

                If(echosignAgreement.get('Additional_CC_User'+i+'__c') != null)
                {
                    Id TempId = (id) echosignAgreement.get('Additional_CC_User'+i+'__c');
                    string sEmail  = UserMAP.get(TempId).email;
                    If( string.isNotBlank(sEmail))
                    {
                        If(! sCCEmail.endsWith(',') &&  ! sCCEmail.endsWith(';') )
                        {
                            sCCEmail = sCCEmail + ';';
                        }

                        sCCEmail = sCCEmail +  sEmail;
                    }
                }
            }
            While(sCCEmail.contains(';;'))
            {
                sCCEmail =sCCEmail.replace(';;', ';');
            }
            If(sCCEmail.left(1) == ';')
            {
                sCCEmail = sCCEmail.mid(1, sCCEmail.length());
            }
            echosignAgreement.echosign_dev1__Cc__c = sCCEmail;

        }


    }


     /*
    ** @author : Mukesh, Apttus Inc.
    ** @date : 05/19/2016
    ** @description : This method is used to default message based on selling country of proposal
    ** @paramaters : Echosign Agreement List
    ** @returns :
	** I-212256 changes
    */
      public void setDefaultDisclaimer(List<echosign_dev1__SIGN_Agreement__c> NewList)
    {
        //List<echosign_dev1__SIGN_Agreement__c> aggList=[select id,Apttus_QPESign__Apttus_Proposal__c from echosign_dev1__SIGN_Agreement__c where id = :NewList];

        MAP<id,echosign_dev1__SIGN_Agreement__c> ProposalEchoSignMap = new MAP<id,echosign_dev1__SIGN_Agreement__c>();
        MAP<string,string> countryToDisclaimerMAP = new MAP<string,string>();
        system.debug('setDefaultDisclaimer method invoked');
        for(echosign_dev1__SIGN_Agreement__c OAgr : NewList)
        {
        	ProposalEchoSignMap.put(OAgr.Apttus_QPESign__Apttus_Proposal__c,OAgr);
        }
        for(Echosign_Agreement_Disclaimer_Mapping__c echoSignDisclaimer: [select id,Selling_Country__c,Disclaimer__c
                                                           from Echosign_Agreement_Disclaimer_Mapping__c])
        {
            countryToDisclaimerMAP.put(echoSignDisclaimer.Selling_Country__c , echoSignDisclaimer.Disclaimer__c);
        }
        for(Apttus_Proposal__Proposal__c oProp: [select id,Selling_Country__c
                                           	FROm Apttus_Proposal__Proposal__c where id= :ProposalEchoSignMap.keySet() ])
        {
            If(String.isNotBlank(oProp.Selling_Country__c) &&  countryToDisclaimerMAP.containsKey(oProp.Selling_Country__c) && !ProposalEchoSignMap.get(oProp.id).APTS_Message_Update_flag__c)
            {
                ProposalEchoSignMap.get(oProp.id).echosign_dev1__Message__c  = countryToDisclaimerMAP.get(oProp.Selling_Country__c);
                ProposalEchoSignMap.get(oProp.id).APTS_Message_Update_flag__c =true;
                system.debug('If block ');
                system.debug('oProp.id '+ oProp.id);
                system.debug('agreement -- > '+ ProposalEchoSignMap.get(oProp.id) );
                system.debug('Echosign Message '+countryToDisclaimerMAP.get(oProp.Selling_Country__c) );
            }
            else if(String.isNotBlank(oProp.Selling_Country__c) && !ProposalEchoSignMap.get(oProp.id).APTS_Message_Update_flag__c)
            {
                if(countryToDisclaimerMAP.containsKey('Catch All'))
                ProposalEchoSignMap.get(oProp.id).echosign_dev1__Message__c  = countryToDisclaimerMAP.get('Catch All');

                ProposalEchoSignMap.get(oProp.id).APTS_Message_Update_flag__c =true;
                system.debug('else If block ');
                system.debug('oProp.id '+ oProp.id);
                system.debug('agreement -- > '+ ProposalEchoSignMap.get(oProp.id) );
                system.debug('Echosign Message '+countryToDisclaimerMAP.get(oProp.Selling_Country__c) );
            }

        }
    }

/*
** @author : JFreese Appirio S-473744
** @date : 4/12/17
** @description : Check the updated agreement and if the signature is resolved, start the order creation process
*/
    public void createOrder(List<echosign_dev1__SIGN_Agreement__c> pAgree , MAP<id,echosign_dev1__SIGN_Agreement__c> OldAgreeMAP){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','createOrder');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        Set<Id> OppSet = new Set<Id>();
        List<echosign_dev1__SIGN_Agreement__c> ags = [SELECT Id,
                                                      echosign_dev1__Status__c,
                                                      echosign_dev1__Data_Mapping_Result__c,
                                                      echosign_dev1__Data_Mapping_Error__c,
                                                      echosign_dev1__Opportunity__c,
                                                      echosign_dev1__Opportunity__r.orderCreated__c
                                                      FROM echosign_dev1__SIGN_Agreement__c WHERE Id IN: pAgree];

        for (echosign_dev1__SIGN_Agreement__c ag : ags){
            String dbg = '^^^Agreement ID='+ag.Id+', Status ='+ag.echosign_dev1__Status__c+', Data_Mapping_Result='+ag.echosign_dev1__Data_Mapping_Result__c;
            if (ag.echosign_dev1__Opportunity__c != null){
                dbg += ', echosign_dev1__Opportunity__r.OrderCreated__c='+ag.echosign_dev1__Opportunity__r.orderCreated__c;
            }
            dbg += ', echosign_dev1__Data_Mapping_Error__c='+ag.echosign_dev1__Data_Mapping_Error__c;
            system.debug(dbg);

            if (ag.echosign_dev1__Status__c == 'Signed' &&
                ag.echosign_dev1__Data_Mapping_Result__c != null &&
                ag.echosign_dev1__Data_Mapping_Result__c != OldAgreeMAP.get(ag.Id).echosign_dev1__Data_Mapping_Result__c &&
                (ag.echosign_dev1__Data_Mapping_Result__c == 'Completed' ||
                 ag.echosign_dev1__Data_Mapping_Result__c == 'Failed') &&
                ag.echosign_dev1__Opportunity__c != null &&
                ag.echosign_dev1__Opportunity__r.orderCreated__c != true)
            {
                system.debug('Ready to generate Order');
                OppSet.add(ag.echosign_dev1__Opportunity__c);
            }else{
                dbg = 'Not ready to generate Order (';
                if (ag.echosign_dev1__Status__c != 'Signed') dbg += 'agreement not signed)';
                else if (ag.echosign_dev1__Data_Mapping_Result__c == null) dbg += 'no Data Mapping result)';
                else if (ag.echosign_dev1__Data_Mapping_Result__c == OldAgreeMAP.get(ag.Id).echosign_dev1__Data_Mapping_Result__c)
                    dbg += 'Data Mapping result has not changed)';
                else if (ag.echosign_dev1__Data_Mapping_Result__c != 'Completed' &&
                         ag.echosign_dev1__Data_Mapping_Result__c != 'Failed') dbg += 'Data Mapping not changed to Completed or Failed)';
                else if (ag.echosign_dev1__Opportunity__c == null) dbg += 'there is no opportunity for this agreement)';
                else if (ag.echosign_dev1__Opportunity__r.orderCreated__c != true) dbg += 'order already exists)';

                system.debug(dbg);
            }
        }

        //Appirio JFreese S-481980 updated to fix logic (this block was in the for loop above)
        Boolean newMethod = Boolean.valueOf(orgSettings.Echosign_Order_Via_Agreement_Trigger__c); //JFreese Appirio 4/12/17 S-473744
        if(OppSet.size() > 0){
            if (newMethod){
                System.debug('----enqueueing job OppSet ' + OppSet);
                ID jobID = System.enqueueJob(new APTS_echoSign_IQueue(OppSet));
                System.debug('----enqueued job ID '+jobID);
            }else{
                System.debug('Not APTS_echoSign_IQueue(OppSet) here, using the original method in ApttusProposalTriggerHelper');
            }
        }
    }
}