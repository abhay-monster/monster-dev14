/*
** @author : Appirio Inc (Jeff L)
** @date : 09/27/16
** @description : This is needed due to an bug in SFDC with the javascript update function
** @summary : After working on this issue for weeks with Salesforce support it turns out there is a bug in the javascript
              API.  What was happening was that if two records were set to update in a single sforce.connection.update
              if one of those records failed due to a validation rule, it didn't roll back the whole transaction
              so the second record would still be updated without issue.  this would be fine, but for some reason
              it also would stop any asychronous methods that were invoked.  So if a future or a Queueable was
              called for the successful record, it would never actually execute.
              performing the logic this way ensures that both records will correctly get rejected and they will not
              have one that works and one that does not.
*/
global class CreditAndRebillUpdateWebService {

    webservice static String updateRecords(List<Id> idList){

        List<Order__c> updatedOrderList = new List<Order__c>();
        
        for(Id orderId : idList){
            Order__c updateOrder = new Order__c(Id=orderId);
            updateOrder.OrderStatus__c = 'Sent To Verification';
            updateOrder.SentToVerificationBy2__c = UserInfo.getUserId();

            updatedOrderList.add(updateOrder);
        }

        update updatedOrderList;
        return 'Success';

    }
}