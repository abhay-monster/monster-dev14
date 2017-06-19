global class ArchiveAccountBatch implements Database.Batchable<sObject>, Database.Stateful{

  global String updateErrors = '';
  global Integer batch_ct = 0;
  global Integer record_ct = 0;
  global Integer scopeSize = 0;
  global Integer acc_ct = 0;
  global Integer qp_ct = 0;
  global Integer opp_ct = 0;
  global Integer case_ct = 0;
  global Integer xcA_ct = 0;
  global Integer xc_ct = 0;

  global Database.QueryLocator start(Database.BatchableContext BC){

     String query = 'SELECT Id FROM Account WHERE ArchivalStatus__c != \'Archived\'';
        system.debug('Query >> '+ query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope){

      batch_ct++;
      record_ct += scope.size();
      if (scopeSize ==0){scopeSize = scope.size();}

      Id archiver = BatchUser__c.getInstance('Archiver').ID__c;
      system.debug('Check 1' + scope);
      Set<Account> tobeUpdated = new Set<Account>();
      Date dateThreeMonths = system.today().addDays(-90);

      Map<Id, Opportunity> childOpp = new Map<Id, Opportunity>();
      Map<Id, Order__c> childOrder = new Map<Id, Order__c>();
      Map<Id, Apttus_Proposal__Proposal__c> childProposal = new Map<Id, Apttus_Proposal__Proposal__c>();
      Map<Id,Order_Line_Item__c> tobeUpdateOli = new Map<Id,Order_Line_Item__c>();
      Map<Id, Opportunity> futureOpp = new Map<Id, Opportunity>();
      Map<Id, Xcode__c> childXcode = new Map<Id, Xcode__c>();
      Map<Id, XcodeAccount__c> childXcodeAcct = new Map<Id, XcodeAccount__c>();

      List<AccountHistory> oppIds = [SELECT Id,OldValue,NewValue,CreatedDate FROM AccountHistory
                                        where Field='Owner' and CreatedDate = LAST_N_DAYS:90];



      //Create a map of accounts to exclude which have opportunities with an Estimated Closed Date in the future.
      for(Opportunity oppFuture : [Select Id, AccountId,CreatedDate,CloseDate From Opportunity Where
                                  CloseDate > :system.today() AND AccountId IN :scope]){
          futureOpp.put(oppFuture.AccountId , oppFuture);
      }
      system.debug('Check >>>>>>>>>futureOpp>>>>>>>>>>' + futureOpp);


      //Create maps of accounts to exclude which have opps, orders, proposals and activities which are less than 90 days old
      for(Opportunity oppFirst : [Select Id, AccountId,CreatedDate From Opportunity Where
                                  CreatedDate > :dateThreeMonths AND AccountId IN :scope]){
          childOpp.put(oppFirst.AccountId , oppFirst);
      }
      system.debug('Check >>>>>>>>>childOpp>>>>>>>>>>' + childOpp);

      for(Order__c ordFirst : [Select Id, Account__c, CreatedDate  from Order__c Where
                              CreatedDate > :dateThreeMonths AND Account__c IN :scope]){
          childOrder.put(ordFirst.Account__c ,ordFirst );
      }
      system.debug('Check >>>>>>>>>childOrder>>>>>>>>>>' + childOrder);

      for(Apttus_Proposal__Proposal__c proFirst : [Select Id, CreatedDate, Apttus_Proposal__Account__c from
                                                  Apttus_Proposal__Proposal__c Where CreatedDate > :dateThreeMonths AND
                                                  Apttus_Proposal__Account__c IN :scope]){
          childProposal.put(proFirst.Apttus_Proposal__Account__c , proFirst );
      }
      system.debug('Check >>>>>>>>>childProposal>>>>>>>>>>' + childProposal);

      if(!childOrder.isEmpty()){
          for(Order_Line_Item__c oli : [Select EndDate__c,Order__c,Order__r.Account__c From Order_Line_Item__c Where EndDate__c >= :system.today()
                                       AND Order__c IN :childOrder.keyset()]){
                 tobeUpdateOli.put(oli.Order__r.Account__c, oli);
          }
      }
      system.debug('Check >>>>>>>>>tobeUpdateOli>>>>>>>>>>' + tobeUpdateOli);

      Map<Id, Event> childActivity = new Map<Id, Event>();
      for(Event eventFirst : [Select Id, WhatId, CreatedDate From Event Where CreatedDate > :dateThreeMonths AND WhatId IN :scope]){
            childActivity.put(eventFirst.WhatId,eventFirst);
      }
      system.debug('Check >>>>>>>>>childActivity>>>>>>>>>>' + childActivity);

      Map<Id, Case> caseChild = new Map<Id, Case>();
      for(Case caseFirst : [Select AccountId from Case Where AccountID IN :scope]){
              caseChild.put(caseFirst.AccountId , caseFirst);
      }
      system.debug('Check >>>>>>>>>caseChild>>>>>>>>>>' + caseChild);


      for(Account accFirst :[Select Id, OwnerId, Owner.Name, Owner.Profile.Name, DateOwnerChanged__c, DunsNumber, CreatedDate, CreditStatus__c, ParentID,
                                    Primary_Sales_Rep__c, PrimaryServiceRep__c,AccountStatus__c,ArchivalStatus__c  From Account where Id IN :scope]){


          if(!childOpp.containsKey(accFirst.id) && !childOrder.containsKey(accFirst.id) && !childProposal.containsKey(accFirst.id)){
                if(accFirst.AccountStatus__c == 'OUT of BUSINESS' && !tobeUpdateOli.containsKey(accFirst.id)){
                    accFirst.OwnerId = archiver;
                    accFirst.ArchivalStatus__c = 'Archived';
                    tobeUpdated.add(accFirst);
                }
                if(accFirst.AccountStatus__c == 'Candidate' && !childActivity.containsKey(accFirst.id) && !futureOpp.containsKey(accFirst.id) &&
                   accFirst.DunsNumber == null &&  accFirst.CreatedDate < system.today().addYears(-1) &&
                   accFirst.parentId == null){
                    accFirst.OwnerId = archiver;
                    accFirst.ArchivalStatus__c = 'Archived';
                    tobeUpdated.add(accFirst);
                }
          }

          if (accFirst.Owner.Name == 'APAC_DEL'){
                  accFirst.OwnerId = archiver;
                  accFirst.ArchivalStatus__c = 'Archived';
                  tobeUpdated.add(accFirst);
          }

          if((accFirst.CreditStatus__c == 'OK' || accFirst.CreditStatus__c == NULL) && !tobeUpdateOli.containsKey(accFirst.id)){
            if (accFirst.Owner.Name == 'INACIVE'){
                  accFirst.OwnerId = archiver;
                  accFirst.ArchivalStatus__c = 'Archived';
                  tobeUpdated.add(accFirst);
            }
            if (accFirst.Owner.profile.name == 'Monster SADMIN' && !caseChild.containsKey(accFirst.id) &&
               ((accFirst.DateOwnerChanged__c == NULL && accFirst.CreatedDate < dateThreeMonths) ||
               (accFirst.DateOwnerChanged__c != NULL && accFirst.DateOwnerChanged__c < dateThreeMonths))){
                  accFirst.OwnerId = archiver;
                  accFirst.ArchivalStatus__c = 'Archived';
                  tobeUpdated.add(accFirst);
            }
          }
      }

      List<Apttus_Proposal__Proposal__c> proposalUpdate = new List<Apttus_Proposal__Proposal__c>();
      List<Opportunity> oppUpdate = new List<Opportunity>();
      List<Case> caseUpdate = new List<Case>();

      for(Apttus_Proposal__Proposal__c proposalFirst: [Select OwnerId, Apttus_Proposal__Account__c ,ArchivalStatus__c, Id
                                                              From Apttus_Proposal__Proposal__c Where Apttus_Proposal__Account__c IN :tobeUpdated]){

          proposalFirst.OwnerId = archiver;
          proposalFirst.ArchivalStatus__c  = 'Archived';
          proposalUpdate.add(proposalFirst);
      }
      if(!proposalUpdate.isEmpty()){
          system.debug('Check >>>>>>>>>proposalUpdate>>>>>>>>>>' + proposalUpdate);
          qp_ct += proposalUpdate.size();
          updateErrors += ArchiveHelper.doUpdate('Apttus_Proposal__Proposal__c', proposalUpdate);
      }

      for(Opportunity oppfirst : [Select Id, OwnerId, AccountId From Opportunity Where AccountId IN :tobeUpdated]){
              oppFirst.OwnerId = archiver;
              oppfirst.ArchivalStatus__c = 'Archived';
              oppUpdate.add(oppfirst);
      }

      if(!oppUpdate.isEmpty()){
          system.debug('Check >>>>>>>>>oppUpdate>>>>>>>>>>' + oppUpdate);
          opp_ct += oppUpdate.size();
          updateErrors += ArchiveHelper.doUpdate('Opportunity', oppUpdate);
      }

      for(Case caseFirst : [Select Id, OwnerId, AccountId From Case Where AccountId IN :tobeUpdated]){
          caseFirst.OwnerId = archiver;
          caseFirst.ArchivalStatus__c = 'Archived';
          caseUpdate.add(caseFirst);
      }

      if(!caseUpdate.isEmpty()){
          system.debug('Check >>>>>>>>>caseUpdate>>>>>>>>>>' + caseUpdate);
          case_ct += caseUpdate.size();
          updateErrors += ArchiveHelper.doUpdate('Case', caseUpdate);
      }

      List<XcodeAccount__c> XcodeAcctUpdate = new List<XcodeAccount__c>();
      List<Xcode__c> XcodeUpdate = new List<Xcode__c>();
      Set<Id> Xcodes = new Set<Id>();
      Set<Id> Xcodes2Archive = new Set<Id>();

      //Gather all XcodeAccount__c records for the Accounts :tobeUpdated
      for(XcodeAccount__c XcodeAcctFirst : [Select Id, Account__c, Xcode__c, IsPrimary__c From XcodeAccount__c Where Account__c IN :tobeUpdated]){
          XcodeAcctFirst.ArchivalStatus__c = 'Archived';
          XcodeAcctUpdate.add(XcodeAcctFirst);

          Xcodes.add(XcodeAcctFirst.Xcode__c);
      }

      if(!XcodeAcctUpdate.isEmpty()){
          system.debug('Check >>>>>>>>>XcodeAcctUpdate>>>>>>>>>>' + XcodeAcctUpdate);
          xcA_ct += XcodeAcctUpdate.size();
          updateErrors += ArchiveHelper.doUpdate('XcodeAccount__c', XcodeAcctUpdate);
      }

      //Gather the Xcode__c values which are only used by the Account :tobeUpdated, no other accounts
      AggregateResult[] AcctCount = [SELECT Xcode__c, COUNT(Id) ct FROM XcodeAccount__c WHERE Xcode__c IN :Xcodes GROUP BY Xcode__c];
      for(AggregateResult ac : AcctCount){
         if(Double.valueOf(ac.get('ct')) == 1){
           Xcodes2Archive.add((Id)ac.get('Xcode__c'));
         }
      }

      //Gather the corresponding Xcode__c records for archiving
      if(!Xcodes2Archive.isEmpty()){
          for(Xcode__c xc : [Select Id, OwnerId, Name From Xcode__c WHERE Id IN :Xcodes2Archive]){
            xc.OwnerId = archiver;
            xc.ArchivalStatus__c = 'Archived';
            XcodeUpdate.add(xc);
          }
      }

      if(!XcodeUpdate.isEmpty()){
          system.debug('Check >>>>>>>>>XcodeUpdate>>>>>>>>>>' + XcodeUpdate);
          xc_ct += XcodeUpdate.size();
          updateErrors += ArchiveHelper.doUpdate('Xcode__c', XcodeUpdate);
      }

      List<Account> tobeUpdatedli = new List<Account>();
      tobeUpdatedli.addAll(tobeUpdated);

      if(!tobeUpdatedli.isEmpty()){
        system.debug('Check >>>>>>>>>Account>>>>>>>>>>' + tobeUpdatedli);
        acc_ct += tobeUpdatedli.size();
        updateErrors += ArchiveHelper.doUpdate('Account', tobeUpdatedli);
      }
    }

      global void finish(Database.BatchableContext BC){
        String objectName = 'Account';
        String summary = '';
        summary += record_ct + ' ' + objectName + ' records were processed ';
        summary += 'in ' + batch_ct + ' batches of up to ' + scopeSize + ' records each.<BR><BR>';
        summary += 'The following counts of records were flagged for archiving:<BR>';
        summary += acc_ct + ' ' + objectName + ' record(s)<BR>';
        summary += qp_ct + ' Quote/Proposal record(s)<BR>';
        summary += opp_ct + ' Opportunity record(s)<BR>';
        summary += case_ct + ' Case record(s)<BR>';
        summary += xcA_ct + ' XcodeAccount__c record(s)<BR>';
        summary += xc_ct + ' Xcode__c record(s)<BR>';
        ArchiveHelper.sendEmail(objectName, summary, updateErrors);
    }
}