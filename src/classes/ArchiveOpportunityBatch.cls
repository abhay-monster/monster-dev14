global class ArchiveOpportunityBatch implements Database.Batchable<sObject>, Database.Stateful{

    global String updateErrors = '';
    global Integer batch_ct = 0;
    global Integer record_ct = 0;
    global Integer scopeSize = 0;
    global Integer opp_ct = 0;
    global Integer qp_ct = 0;


    global Database.QueryLocator start(Database.BatchableContext BC){
        Id opportunityId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity');
        Id opportunityLockedId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Opportunity Locked');
        //Id leadOppId = Utility.GetRecordTypeIdBySObjectNameAndType('Opportunity', 'Lead');
        String query = 'SELECT Id, OwnerId, AccountId,Status__c, Organization__c, CreatedDate,CloseDate FROM Opportunity WHERE ArchivalStatus__c != \'Archived\' ' +
                              'AND (recordTypeId = \'' + opportunityId + '\' OR recordTypeId = \'' + opportunityLockedId + '\')';
        system.debug('Query >> '+ query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        batch_ct++;
        record_ct += scope.size();
        if (scopeSize ==0){scopeSize = scope.size();}

        Id archiver = BatchUser__c.getInstance('Archiver').ID__c;
        List<Opportunity>  opportunityToUpdate = new List<Opportunity>();
        List<Apttus_Proposal__Proposal__c>  quoteToUpdate = new List<Apttus_Proposal__Proposal__c>();
        set<Id> opportunityId = new Set<Id>();
        //Added values to opportunity Id
        for(Opportunity opp : scope)
        	opportunityId.add(opp.Id);
        set<Id> orderId = new set<Id>();
        set<Id> archivedOpps = new Set<Id>();
        map<Id, List<Order__c>> oppOrderMap = new map<Id, List<Order__c>>();
        map<Id, List<Order_Line_Item__c>> oppOrderLineItemMap = new map<Id, List<Order_Line_Item__c>>();
        List<Order__c> orderList = [SELECT Id,Opportunity__c FROM Order__c WHERE Opportunity__c = :opportunityId AND (OrderStatus__c = 'Sent To Verification' OR OrderStatus__c = 'Verified')];
        for(Order__c ord : orderList){

            if(!oppOrderMap.keySet().contains(ord.Opportunity__c)){
                oppOrderMap.put(ord.Opportunity__c, new List<Order__c>());
            }
                oppOrderMap.get(ord.Opportunity__c).add(ord);
        }
        List<Order_Line_Item__c> orderLIList = [SELECT Id,Order__c, Order__r.Opportunity__c FROM Order_Line_Item__c WHERE Order__r.Opportunity__c = :opportunityId AND
                                                Order__r.OrderStatus__c != 'Sent To Verification' AND Order__r.OrderStatus__c != 'Verified'
                                                AND EndDate__c > :system.today()];
        for(Order_Line_Item__c oLI : orderLIList){

            if(!oppOrderLineItemMap.keySet().contains(oLI.Order__r.Opportunity__c)){
                oppOrderLineItemMap.put(oLI.Order__r.Opportunity__c, new List<Order_Line_Item__c>());
            }
                oppOrderLineItemMap.get(oLI.Order__r.Opportunity__c).add(oLI);
        }
        if(!scope.isEmpty()){
            for(Opportunity opp : scope){
                if(opp.AccountId == null){
                    opp.OwnerId = archiver;
                    opp.ArchivalStatus__c = 'Archived';
                    opportunityToUpdate.add(opp);
                    archivedOpps.add(opp.Id);
                } else if(opp.Organization__c != 'Asia Pacific' && opp.CreatedDate < system.today().addYears(-2)
                && (oppOrderMap.get(opp.Id) == null  || oppOrderMap.get(opp.Id).size() == 0) &&
                (oppOrderLineItemMap.get(opp.Id) == null  || oppOrderLineItemMap.get(opp.Id).size() == 0)
                && opp.CloseDate < system.now().addDays(-90)){
                    opp.OwnerId = archiver;
                    opp.ArchivalStatus__c = 'Archived';
                    opportunityToUpdate.add(opp);
                    archivedOpps.add(opp.Id);
                }else if(opp.Organization__c == 'Asia Pacific' && opp.CreatedDate < system.today().addYears(-1)
                        && opp.Status__c != 'Won' && opp.Status__c != 'Order Created' && opp.Status__c != 'Submitted to Finance' && opp.Status__c != 'Verified by Finance'
                        && opp.CloseDate < system.now().addDays(-90)) {
                    opp.OwnerId = archiver;
                    opp.ArchivalStatus__c = 'Archived';
                    opportunityToUpdate.add(opp);
                    archivedOpps.add(opp.Id);
                }
            }
            if(opportunityToUpdate.size() > 0){
                opp_ct += opportunityToUpdate.size();
                updateErrors += ArchiveHelper.doUpdate('Opportunity', opportunityToUpdate);
            }

            for(Apttus_Proposal__Proposal__c quotes : [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Opportunity__c IN :archivedOpps]){
                quotes.OwnerId = archiver;
                quotes.ArchivalStatus__c = 'Archived';
                quoteToUpdate.add(quotes);
            }
            if(quoteToUpdate.size() > 0){
                Database.Update(quoteToUpdate);
                qp_ct += quoteToUpdate.size();
                updateErrors += ArchiveHelper.doUpdate('Apttus_Proposal__Proposal__c', quoteToUpdate);
            }
        }
    }
    global void finish(Database.BatchableContext BC){
        String objectName = 'Opportunity';
        String summary = '';
        summary += record_ct + ' ' + objectName + ' records were processed ';
        summary += 'in ' + batch_ct + ' batches of up to ' + scopeSize + ' records each.<BR><BR>';
        summary += 'The following counts of records were flagged for archiving:<BR>';
        summary += opp_ct + ' Opportunity record(s)<BR>';
        summary += qp_ct + ' Quote/Proposal record(s)<BR>';
        ArchiveHelper.sendEmail(objectName, summary, updateErrors);
    }
}