trigger Update_oppty_proposal_on_status_Signed on echosign_dev1__SIGN_Agreement__c (After update) {

    system.debug('in trigger Update_oppty_on_status_Signed');
    List<Opportunity> opptylist = new List<Opportunity>();
    MAP<id,Date> MAPAccountMSASigned = new MAP<id,Date>();
    List<Apttus_Proposal__Proposal__c> proplist = new List<Apttus_Proposal__Proposal__c>();
    MAP<id,echosign_dev1__SIGN_Agreement__c> MAPProposalAgreement=  new MAP<id,echosign_dev1__SIGN_Agreement__c>();
    set<id> ProposalIds = new set<id>();
    set<id> opptyIds = new set<id>();
    Boolean isProposalExpired = true;

    //JFreese Appirio 4/12/17 S-473744 Adobe Echosign
    //No idea why this trigger exists just for After Update, but will use it nonetheless
    Profile currentUserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId()];
    system.debug(' currentUserProfile  :'+currentUserProfile);
    private APTS_EchoSignAgreementTriggerHelper helper = APTS_EchoSignAgreementTriggerHelper.NewTriggerHelper(currentUserProfile.Name);


    try{
        for(echosign_dev1__SIGN_Agreement__c eachechosign : Trigger.new){
            //JFreese Appirio 4/13/17 S-473744 Adobe Echosign
            /*Jfreese Appirio 4/26/17 S-481980 Confirm that echosign_dev1__DateSigned__c gets set on
              agreement creation and updated on agreement status == signed, which is key to the unresolved
              agreement fix.  So removed the caution from the debug of DateSigned*/
            String dbg='\n\nSummary of echosign_dev1__SIGN_Agreement__c Agreement ID: '+eachechosign.Id+'\n';
            dbg += 'echosign_dev1__Status__c='+eachechosign.echosign_dev1__Status__c+'\n';
            dbg += 'echosign_dev1__DateSigned__c='+eachechosign.echosign_dev1__DateSigned__c;
            dbg += 'echosign_dev1__Opportunity__c='+eachechosign.echosign_dev1__Opportunity__c+'\n';
            dbg += 'Apttus_QPESign__Apttus_Proposal__c='+eachechosign.Apttus_QPESign__Apttus_Proposal__c+'\n';
            dbg += 'echosign_dev1__Data_Mapping_Result__c='+eachechosign.echosign_dev1__Data_Mapping_Result__c+'\n';
            dbg += 'echosign_dev1__Data_Mapping_Error__c='+eachechosign.echosign_dev1__Data_Mapping_Error__c+'\n\n\n';
            system.debug(dbg);
            if(eachechosign.echosign_dev1__Status__c =='Signed' && eachechosign.Apttus_QPESign__Apttus_Proposal__c != null){
                ProposalIds.add(eachechosign.Apttus_QPESign__Apttus_Proposal__c);
            }
        }
        If(ProposalIds.size() > 0 )
        {


            Map<Id,Apttus_Proposal__Proposal__c>  proplmap = new  Map<Id,Apttus_Proposal__Proposal__c>(
                [select Id, signed_indicator__c,
                 Apttus_Proposal__Opportunity__c,
                 Apttus_Proposal__Opportunity__r.echosign_indicator__c,
                 MSA_checked__c,
                 Apttus_Proposal__Account__r.APTS_MSA_Status__c,
                 Apttus_Proposal__Account__r.APTS_MSA_Start_Date__c,QuoteStatus__c
                 from Apttus_Proposal__Proposal__c where Id in: ProposalIds]);

            for(Apttus_Proposal__Proposal__c eachechosign : proplmap.values()){
                Apttus_Proposal__Proposal__c proposal = eachechosign;
                system.debug('proposal' + proposal);
                Opportunity oppty = eachechosign.Apttus_Proposal__Opportunity__r;
                system.debug('Opportunity:  '+oppty );
                if(oppty != null && !oppty.echosign_indicator__c){
                    oppty.echosign_indicator__c = true;
                    opptylist.add(oppty);
                    opptyIds.add(oppty.Id);
                }
                system.debug('Apttus_Proposal__Proposal__c proposal :'+proposal );
                if(proposal != null && !proposal.signed_indicator__c ){
                    proposal.signed_indicator__c = true;
                     system.debug('Quote Status '+ proposal.QuoteStatus__c);
                    if(proposal.QuoteStatus__c!='Expired'){
                        proposal.Apttus_Proposal__Primary__c=true;//I-209488 changes
                        isProposalExpired =false;
                    }
                    proposal.QuoteStatus__c = 'Accepted Online';

                    System.debug('MS Test111:'+proposal.MSA_checked__c);
                    System.debug('MS Test112:'+proposal.Apttus_Proposal__Account__r.APTS_MSA_Status__c);

                    If(proposal.MSA_checked__c && proposal.Apttus_Proposal__Account__r.APTS_MSA_Status__c!='Signed' &&  (!MAPAccountMSASigned.containsKey(proposal.Apttus_Proposal__Account__c)))
                    {
                        MAPAccountMSASigned.put(proposal.Apttus_Proposal__Account__c,Date.today());
                    }
                    proplist.add(proposal);
                }
            }
            If(!MAPAccountMSASigned.isEmpty())
            {
                map<Id, Account> parentAccountMap = new map<Id, Account>([SELECT id, APTS_MSA_Status__c,APTS_MSA_Start_Date__c
                                                                          FROM Account
                                                                          WHERE Id IN :MAPAccountMSASigned.keySet()]);

                System.debug('MS Test114:'+parentAccountMap);
                for(id Tempid : parentAccountMap.keySet()){

                    parentAccountMap.get(Tempid).APTS_MSA_Status__c = 'Signed';
                    parentAccountMap.get(Tempid).APTS_MSA_Start_Date__c = Date.today();
                }


                AccountTriggerHandler.ExecuteTriggers = false;
                update parentAccountMap.values();
            }
            system.debug('isProposalExpired '+ isProposalExpired);
            //I-209488 changes to make signed proposal primary and other proposals on the same opptortunity non-primary
            if(opptyIds.size()>0 && !proplist.isEmpty() && proplist != null && !isProposalExpired){

                 Map<Id,Apttus_Proposal__Proposal__c>  proposalmap = new  Map<Id,Apttus_Proposal__Proposal__c>(
                [select Id from Apttus_Proposal__Proposal__c where Apttus_Proposal__Opportunity__c  in: opptyIds]);


                 for(Apttus_Proposal__Proposal__c eachOpttyproposal : proposalmap.values()){

                     if(!ProposalIds.contains(eachOpttyproposal.Id) ){

                         eachOpttyproposal.Apttus_Proposal__Primary__c=false;
                         eachOpttyproposal.QuoteStatus__c ='Expired';//I-211343 changes
                         proplist.add(eachOpttyproposal);
                     }


                 }

            }



            if(!opptylist.isEmpty() && opptylist != null)
                update opptylist;
            if(!proplist.isEmpty() && proplist != null){

              //  ApttusProposalTriggerHandler.ExecuteTriggers=false;// changes for locking issue in echosign
                update proplist;
            }

            System.debug('MS Test113:'+MAPAccountMSASigned);
        }

        helper.createOrder(trigger.new , trigger.oldMap); //JFreese Appirio 4/12/17 S-473744
    }
    catch (DmlException de) {
        Integer numErrors = de.getNumDml();
        String Ex = '';
        System.debug('getNumDml=' + numErrors);
        for(Integer i=0;i<numErrors;i++) {
            //System.debug('getDmlFieldNames=' + de.getDmlFieldNames(i));
            //System.debug('getDmlMessage=' + de.getDmlMessage(i));
            Ex += de.getDmlMessage(i);
        }
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Ex));
    }

}