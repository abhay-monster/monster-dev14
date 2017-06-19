public with sharing class APTS_QuoteHeaderOverride_Ctlr {
    final String CLASSNAME = '\n\n**** APTS_QuoteHeaderOverride_Ctlr.METHODNAME()';
    private Apttus_Proposal__Proposal__c proposal;
    public  Apttus_Proposal__Proposal__c proposalSO{get;set;}
    public boolean addComments{get;set;}
    
    public APTS_QuoteHeaderOverride_Ctlr(ApexPages.StandardController stdController) {
        proposal = (Apttus_Proposal__Proposal__c)stdController.getRecord();        
        addComments = false;
    }
    
    public PageReference doRedirect() {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','doRedirect');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        PageReference pg;
         
        if(proposal != null) {
            proposal = [Select APTS_Enforce_Rollup_Summary_Calc__c, APTS_Fire_Approvals__c, APTS_Count_Of_Agency_Comm_Diff_Lines__c, 
                TotalBaseExtendedPrice__c, GrossOrderAmount__c,Net_Total__c,
                 // Quote_Total__c - Commented due to I-191155 
                 ownerId, TotalDiscount__c, Manager1__c, 
                Discount_Authority_Manager1__c, Manager2__c, Discount_Authority_Manager2__c, Manager3__c, Discount_Authority_Manager3__c, 
                Manager4__c, Discount_Authority_Manager4__c, Manager5__c, Discount_Authority_Manager5__c, Manager6__c, Discount_Authority_Manager6__c, 
                Manager7__c, Discount_Authority_Manager7__c, Manager8__c, Discount_Authority_Manager8__c, Manager9__c, Discount_Authority_Manager9__c, 
                Manager10__c, Discount_Authority_Manager10__c, AgencyCommission__c
                From Apttus_Proposal__Proposal__c Where Id = :proposal.Id];
                
            if(proposal.APTS_Enforce_Rollup_Summary_Calc__c || proposal.APTS_Fire_Approvals__c) {
                doRollupSummaryCalc(proposal);
                proposal.APTS_Enforce_Rollup_Summary_Calc__c = false;
                
                Boolean fireApprovals = proposal.APTS_Fire_Approvals__c;
                
                if(fireApprovals) {
                    addComments = true;
                    pg = null;
                }
                else {
                    addComments = false;
                    pg = new PageReference('/' + proposal.Id + '?nooverride=1');
                }
                 
                ApttusProposalTriggerHandler.ExecuteTriggers = false;                
                update proposal;
            }
            else{
                pg = new PageReference('/' + proposal.Id + '?nooverride=1');
            }

        }
     
        return pg;
    }
    
    public Pagereference submitforApprovalswithComment(){
      
      final string METHODNAME = CLASSNAME.replace('METHODNAME','submitforApprovalswithComment');
      PageReference returnPage;
      
      proposalSO = [Select Id,Name,APTS_Enforce_Rollup_Summary_Calc__c,APTS_Fire_Approvals__c,Approval_Comments__c,
                              ownerId,
                              TotalDiscount__c,
                              Manager1__c,
                              Discount_Authority_Manager1__c,
                              Manager2__c,
                              Discount_Authority_Manager2__c,
                              Manager3__c,
                              Discount_Authority_Manager3__c,
                              Manager4__c,
                              Discount_Authority_Manager4__c,
                              Manager5__c,
                              Discount_Authority_Manager5__c,
                              Manager6__c,
                              Discount_Authority_Manager6__c,
                              Manager7__c,
                              Discount_Authority_Manager7__c,
                              Manager8__c,
                              Discount_Authority_Manager8__c,
                              Manager9__c,
                              Discount_Authority_Manager9__c,
                              Manager10__c,
                              Discount_Authority_Manager10__c
                             From Apttus_Proposal__Proposal__c Where Id = :proposal.Id];
        
      boolean submitApprovals = proposalSO.APTS_Fire_Approvals__c;
      
      if(submitApprovals){
          List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();
          proposalList.add(proposalSO);
          AptsQuoteApprovalHelper.updateManager(proposalList);
          proposalSO.APTS_Fire_Approvals__c = false;
      }
      
      ApttusProposalTriggerHandler.ExecuteTriggers = false;
      update proposalSO;
      
      if(submitApprovals){
          try {
               submitForApprovals('Apttus_Proposal__Proposal__c', proposalSO.Id,proposalSO.Approval_Comments__c);
               ApttusProposalTriggerHandler.ExecuteTriggers = true;
           } catch(Exception e) {
                 String errorMsg = e.getMessage();
                 if(errorMsg == 'Approval Process entry criteria not satisfied for Quote/Proposal.') {
                     proposalSO.Apttus_QPApprov__Approval_Status__c = 'Approved';
                     update proposalSO;
                     ApttusProposalTriggerHandler.ExecuteTriggers = true;
                 } else {
                     ApttusProposalTriggerHandler.ExecuteTriggers = true;
                     throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details.', e);
                 }
          }
          
          returnPage = New PageReference('/' + proposalSO.Id + '?nooverride=1');
          
    }
    else{
        returnPage = New PageReference('/' + proposalSO.Id + '?nooverride=1');
    }
        return returnPage;
    }

    private void submitForApprovals(String objectAPIName, String objectId, String submissionComments) {
        
        if(submissionComments != null && submissionComments.trim() != '') {
            Apttus_Approval.SubmissionComments comments = Apttus_Approval.ApprovalsWebService.checkIfCommentsRequired(objectId, objectAPIName);
            
            if(comments != null) {
                comments.setProcessComment(submissionComments);
            
                Apttus_Approval.ApprovalsWebService.submitForApprovalsWithComments(objectAPIName, objectId, comments);
            } else {
                Apttus_Approval.ApprovalsWebService.submitForApprovals(objectAPIName, objectId); 
            }
        } else {
            Apttus_Approval.ApprovalsWebService.submitForApprovals(objectAPIName, objectId); 
        }
        
    }
    
    private void doRollupSummaryCalc(Apttus_Proposal__Proposal__c proposal) {
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = [Select Apttus_QPConfig__BaseExtendedPrice__c, Net_Total__c, 
            APTS_Is_Agency_Commission_Different__c, Apttus_QPConfig__OptionPrice__c, Apttus_QPConfig__LineStatus__c, Apttus_QPConfig__NetPrice__c,
            APTS_Extended_List_Price__c
            From Apttus_Proposal__Proposal_Line_Item__c Where Apttus_Proposal__Proposal__c = : proposal.Id];
        
        
        system.debug(LoggingLevel.INFO, 'proposalLineItemList size :::::::::::::::: ' + proposalLineItemList.size());
        
        if(!proposalLineItemList.isEmpty()) {
            system.debug(LoggingLevel.INFO, '111111111111111111111111');
            Integer countOfAgencyCommDiffLines = 0;
            Decimal totalBaseExtendedPrice = 0;
            Decimal grossOrderAmount = 0;
            Decimal quoteTotal = 0;
            Decimal grossTotal = 0;
            Decimal baseTotal = 0;
            
            for(Apttus_Proposal__Proposal_Line_Item__c proposalLineItemObj : proposalLineItemList) {
                system.debug(LoggingLevel.INFO, 'proposalLineItemObj :::::::::::::::::::: ' + proposalLineItemObj);
                countOfAgencyCommDiffLines += Integer.valueOf(proposalLineItemObj.APTS_Is_Agency_Commission_Different__c);
                
                if(proposalLineItemObj.Apttus_QPConfig__OptionPrice__c == null) {
                    quoteTotal += proposalLineItemObj.Net_Total__c;
                    
                    if(proposalLineItemObj.Apttus_QPConfig__LineStatus__c == 'New') {
                        totalBaseExtendedPrice += proposalLineItemObj.Apttus_QPConfig__BaseExtendedPrice__c;
                        grossOrderAmount += proposalLineItemObj.Net_Total__c;
                    } 
                }
                
                grossTotal += (proposalLineItemObj.Apttus_QPConfig__NetPrice__c!=null)?proposalLineItemObj.Apttus_QPConfig__NetPrice__c:0;
                baseTotal +=(proposalLineItemObj.APTS_Extended_List_Price__c!=null)? proposalLineItemObj.APTS_Extended_List_Price__c:0;
                
                //system.debug(LoggingLevel.INFO, 'grossTotal 1 ::::::::::::::::::::::::::::: ' + grossTotal);
                //system.debug(LoggingLevel.INFO, 'baseTotal 1 :::::::::::::::::::::::::::: ' + baseTotal);
            }
            system.debug(LoggingLevel.INFO, 'quoteTotal :::::::::::::::::::: ' + quoteTotal);
            proposal.APTS_Count_Of_Agency_Comm_Diff_Lines__c = countOfAgencyCommDiffLines;
            proposal.TotalBaseExtendedPrice__c = totalBaseExtendedPrice;
            proposal.GrossOrderAmount__c = grossOrderAmount;
            // Commented due to I-191155
            //proposal.Quote_Total__c = quoteTotal;  
            
            //system.debug(LoggingLevel.INFO, 'grossTotal 2 ::::::::::::::::::::::: ' + grossTotal);
            
            /* Jeff L Commented out per I-180896, this should not be calculated
            if(grossTotal != 0) {
                proposal.AgencyCommission__c = (grossTotal - quoteTotal) / grossTotal * 100;  
            } else {
                proposal.AgencyCommission__c = 0;
            }*/
            
            system.debug('APTS_QuoteHeaderOverride_Ctlr');
            //system.debug('grossTotal ::::::::::::::::::::; ' + grossTotal);
            //system.debug('baseTotal ::::::::::::::::::: ' + baseTotal);
            
           if(baseTotal != null && baseTotal > 0) {
                proposal.TotalDiscount__c = (1 - (grossTotal/baseTotal)) * 100;
            }
            
            //system.debug('proposal.TotalDiscount__c :::::::::::::::::::::: ' + proposal.TotalDiscount__c);
            
            
            if(totalBaseExtendedPrice != 0) {
                proposal.TotalDiscount__c = (totalBaseExtendedPrice - grossOrderAmount ) / totalBaseExtendedPrice * 100;
            } else {
                proposal.TotalDiscount__c = 0;
            }
            
        }
    
    }

}