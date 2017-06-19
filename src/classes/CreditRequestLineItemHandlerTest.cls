@isTest
private class CreditRequestLineItemHandlerTest{

 static testMethod void creditRequest(){
 /* Jeff L commented out - no logic is actually performed here anymore
      Account a= new account(name='test',billingcountry='india');
    try{
        insert a;
    }catch(Exception e){
            system.assert(false,'Account not created');
        }

     Order__c order = new Order__c ();
     order.Account__c = a.id;
     try{
         insert  order ;
         }catch(Exception e){
            system.assert(false,'Order not inserted');
        }

     Credit_Request__c creditRequest = new Credit_Request__c ();
     creditRequest .order__c = order.Id;
     try{
     insert creditRequest ;
     }catch(Exception e){
            system.assert(false,'Credit Request not created');
        }

     CreditRequestLineItemTriggerHandler credditRequest = new CreditRequestLineItemTriggerHandler (true,4);
     Test.startTest();
     CreditRequestLineItem__c credit = new CreditRequestLineItem__c();
     credit.CreditCondition__c = 'Full';
     credit.Credit_Request__c = creditRequest .Id;
     try{
         insert credit;
         credit.CreditCondition__c = 'Tax';
         update credit;
       }catch(Exception e){

           system.assert(false,'Credit request Line Item not inserted');
      }


     Test.stopTest();
 */
 }

}