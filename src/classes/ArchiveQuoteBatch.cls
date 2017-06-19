global class ArchiveQuoteBatch implements Database.Batchable<sObject>, Database.Stateful{

  global String updateErrors = '';
  global Integer batch_ct = 0;
  global Integer record_ct = 0;
  global Integer scopeSize = 0;
  global Integer qp_ct = 0;
  global Integer qpli_ct = 0;

  global Database.QueryLocator start(Database.BatchableContext BC){
    date dt = system.today().addDays(-90);
        String query = 'SELECT Id, OwnerId, ArchivalStatus__c, CreatedDate, Order_Type__c, Apttus_Proposal__Valid_Until_Date__c, OpportunityStage__c, ' +
                              'QuoteStatus__c,Organization__c,Apttus_Proposal__Account__c,NSSAType__c FROM Apttus_Proposal__Proposal__c ' +
                              'WHERE ArchivalStatus__c != \'Archived\'';
        system.debug('Query >> '+ query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Apttus_Proposal__Proposal__c> scope){

        batch_ct++;
        record_ct += scope.size();
        if (scopeSize ==0){scopeSize = scope.size();}

        Id archiver = BatchUser__c.getInstance('Archiver').ID__c;
        List<Apttus_Proposal__Proposal__c> quoteListToBeUpdated = new List<Apttus_Proposal__Proposal__c>();
        List<Apttus_Proposal__Proposal_Line_Item__c> lineItemListToBeUpdated = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        Map<Id,Apttus_Proposal__Proposal_Line_Item__c> quoteIdToLineItemMap = new Map<Id,Apttus_Proposal__Proposal_Line_Item__c>();
        Set<Id> quoteIdSet = new Set<Id>();
       // Set<String> organization1 = new set<string>{'Asia Pacific', 'North America', 'Default Organization', 'Temp', 'CSA'};
        //Set<String> organization2 = new set<string>{'Asia Pacific', 'North America','Europe', 'Default Organization', 'Temp', 'CSA'};
        //Set<String> organization3 = new set<string>{'Asia Pacific', 'North America', 'Europe'};


        for(Apttus_Proposal__Proposal_Line_Item__c lineItem : [SELECT Id,Apttus_Proposal__Proposal__c FROM Apttus_Proposal__Proposal_Line_Item__c
                                                                WHERE  Apttus_Proposal__Proposal__c IN :scope]){

                    quoteIdToLineItemMap.put(lineItem.Apttus_Proposal__Proposal__c,lineItem);

        }
        system.debug('Check >>>>>>>>>quoteIdToLineItemMap>>>>>>>>>>' + quoteIdToLineItemMap);
		//Changed the order of If otherwise the 5 and 3 years would never be called
        if(!scope.isEmpty()){
            for(Apttus_Proposal__Proposal__c quote : scope){
                if(quote.CreatedDate < system.today().addYears(-1)
                    //&& organization1.contains(quote.Organization__c)
                    && quote.OpportunityStage__c != 'Order Placed'){

                    quote.ArchivalStatus__c = 'Archived';
                    quote.OwnerId = archiver;
                    quoteListToBeUpdated.add(quote);
                    quoteIdSet.add(quote.Id);
                }else if((quote.CreatedDate < system.today().addDays(-90))
                    && !quoteIdToLineItemMap.containsKey(quote.Id)
                    //&& organization2.contains(quote.Organization__c)
                    ){

                    quote.ArchivalStatus__c = 'Archived';
                    quote.OwnerId = archiver;
                    quoteListToBeUpdated.add(quote);
                    quoteIdSet.add(quote.Id);
                }else if((quote.CreatedDate < system.today().addYears(-3))
                    && quoteIdToLineItemMap.containsKey(quote.Id)
                    // && organization2.contains(quote.Organization__c)
                    ){

                    quote.ArchivalStatus__c = 'Archived';
                    quote.OwnerId = archiver;
                    quoteListToBeUpdated.add(quote);
                    quoteIdSet.add(quote.Id);
                }else if(quote.Apttus_Proposal__Account__c == null
                    //&& organization2.contains(quote.Organization__c)
                    ){

                    quote.ArchivalStatus__c = 'Archived';
                    quote.OwnerId = archiver;
                    quoteListToBeUpdated.add(quote);
                    quoteIdSet.add(quote.Id);
                }else if((quote.CreatedDate < system.today().addYears(-1))
                    && quote.NSSAType__c != 'Long Term Contract'
                    && quote.OpportunityStage__c != 'Order Placed'
                    // && quote.Organization__c == 'Europe'
                    ){

                    quote.OwnerId = archiver;
                    quote.ArchivalStatus__c = 'Archived';
                    quoteListToBeUpdated.add(quote);
                    quoteIdSet.add(quote.Id);
                } else if(quote.NSSAType__c == 'Long Term Contract'
                    && (quote.CreatedDate < system.today().addYears(-5))
                    // &&  quote.Organization__c == 'Europe'
                    ){

                    quote.OwnerId = archiver;
                    quote.ArchivalStatus__c = 'Archived';
                    quoteListToBeUpdated.add(quote);
                    quoteIdSet.add(quote.Id);
                }else if((quote.CreatedDate < system.today().addYears(-2))
                    && (quote.QuoteStatus__c == 'In Progress' || quote.QuoteStatus__c == 'Expired' )
                    //&& organization2.contains(quote.Organization__c)
                    ){

                    quote.OwnerId = archiver;
                    quote.ArchivalStatus__c = 'Archived';
                    quoteListToBeUpdated.add(quote);
                    quoteIdSet.add(quote.Id);
                }else if(quote.CreatedDate < system.today()
                    //&& organization3.contains(quote.Organization__c)
                    && quote.QuoteStatus__c == 'Expired'
                    && quote.Apttus_Proposal__Valid_Until_Date__c != null
                    && quote.Apttus_Proposal__Valid_Until_Date__c < system.today().addDays(-90)) {

                    quote.OwnerId = archiver;
                    quote.ArchivalStatus__c = 'Archived';
                    quoteListToBeUpdated.add(quote);
                    quoteIdSet.add(quote.Id);
                }
            }

            if(quoteListToBeUpdated.size() > 0){
                system.debug('Check >>>>>>>>>quoteListToBeUpdated>>>>>>>>>>' + quoteListToBeUpdated);
                qp_ct += quoteListToBeUpdated.size();
                updateErrors += ArchiveHelper.doUpdate('Apttus_Proposal__Proposal__c', quoteListToBeUpdated);
            }

            if(!quoteIdSet.isEmpty()){
                for(Apttus_Proposal__Proposal_Line_Item__c lineItem : [SELECT Id,ArchivalStatus__c FROM Apttus_Proposal__Proposal_Line_Item__c WHERE
                    Apttus_Proposal__Proposal__c IN :quoteIdSet]){

                   lineItem.ArchivalStatus__c = 'Archived';
                   lineItemListToBeUpdated.add(lineItem);
                }
            }

            if(lineItemListToBeUpdated.size() > 0){
                Database.Update(lineItemListToBeUpdated);
                qpli_ct += lineItemListToBeUpdated.size();
                updateErrors += ArchiveHelper.doUpdate('Apttus_Proposal__Proposal_Line_Item__c', lineItemListToBeUpdated);
                }
        }
    }
    global void finish(Database.BatchableContext BC){
        String objectName = 'Quote/Proposal';
        String summary = '';
        summary += record_ct + ' ' + objectName + ' records were processed ';
        summary += 'in ' + batch_ct + ' batches of up to ' + scopeSize + ' records each.<BR><BR>';
        summary += 'The following counts of records were flagged for archiving:<BR>';
        summary += qp_ct + ' Quote/Proposal record(s)<BR>';
        summary += qpli_ct + ' Quote/Proposal Line Item record(s)<BR>';
        ArchiveHelper.sendEmail(objectName, summary, updateErrors);
    }
}