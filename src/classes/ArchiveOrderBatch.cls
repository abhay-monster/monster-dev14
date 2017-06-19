global class ArchiveOrderBatch implements Database.Batchable<sObject>, Database.Stateful{

  global String updateErrors = '';
  global Integer batch_ct = 0;
  global Integer record_ct = 0;
  global Integer scopeSize = 0;
  global Integer order_ct = 0;
  global Integer oli_ct = 0;

  global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, OrderDate__c, LatestProductEndDate__c, Account__c, CreatedDate, ArchivalStatus__c ' +
                       'FROM Order__c WHERE ArchivalStatus__c != \'Archived\'';
        system.debug('Query >> '+ query);
        return Database.getQueryLocator(query);
    }

     global void execute(Database.BatchableContext BC, List<Order__c> scope){

        batch_ct++;
        record_ct += scope.size();
        if (scopeSize ==0){scopeSize = scope.size();}

        List<Order__c> tobeUpdated = new List<Order__c>();
        List<Order_Line_Item__c> tobeUpdatedOli = new List<Order_Line_Item__c>();
        Map<Id,Order_Line_Item__c> scopeLineItem = new Map<Id,Order_Line_Item__c>();

        for(Order_Line_Item__c oliFirst : [Select Id, Order__c, ArchivalStatus__c From Order_Line_Item__c Where Order__c IN :scope]){
            scopeLineItem.put(oliFirst.Order__c, oliFirst);
        }
        system.debug('Check >>>>>>>>>scopeLineItem>>>>>>>>>>' + scopeLineItem);

        Date yearPastThree = system.today().addyears(-3);
        Date daysPastSixty = system.today().adddays(-60);

        for(Order__c ordFirst : scope){

            if(ordFirst.OrderDate__c < yearPastThree || ordFirst.LatestProductEndDate__c < yearPastThree ){
                ordFirst.ArchivalStatus__c = 'Archived';
                tobeUpdated.add(ordFirst);
            }
            else if(!scopeLineItem.containsKey(ordFirst.id) && ordFirst.OrderDate__c < daysPastSixty){
                ordFirst.ArchivalStatus__c = 'Archived';
                tobeUpdated.add(ordFirst);
            }
            else if(ordFirst.Account__c == null){
                ordFirst.ArchivalStatus__c = 'Archived';
                tobeUpdated.add(ordFirst);
            }
        }

        if(!tobeUpdated.isEmpty()){

            for(Order_Line_Item__c oliLast : [Select Id, Order__c From Order_Line_Item__c Where Order__c IN :tobeUpdated]){
                oliLast.ArchivalStatus__c = 'Archived';
                tobeUpdatedOli.add(oliLast );
            }

            order_ct += tobeUpdated.size();
            updateErrors += ArchiveHelper.doUpdate('Order__c', tobeUpdated);
        }

        if(!tobeUpdatedOli.isEmpty()){
           oli_ct += tobeUpdatedOli.size();
           updateErrors += ArchiveHelper.doUpdate('Order_Line_Item__c', tobeUpdatedOli);
        }
     }
     global void finish(Database.BatchableContext BC){
        String objectName = 'Order__c';
        String summary = '';
        summary += record_ct + ' ' + objectName + ' records were processed ';
        summary += 'in ' + batch_ct + ' batches of up to ' + scopeSize + ' records each.<BR><BR>';
        summary += 'The following counts of records were flagged for archiving:<BR>';
        summary += order_ct + ' ' + objectName + ' record(s)<BR>';
        summary += oli_ct + ' Order_Line_Item__c record(s)<BR>';
        ArchiveHelper.sendEmail(objectName, summary, updateErrors);
    }

    }