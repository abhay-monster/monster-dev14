global class OrderTriggerHelperGlobal {
        /*
    ** @author : Gaurav Gupta
    ** @date : 08/02/2017
    ** @story : S-467504
    ** @Issue :
    ** @description : Update Order in future call to avoid too many soql
    ** @paramaters : Order Id
    ** @returns : nothing
    */

    webservice static void  verifyOrderInFuture(Id orderId , String orderStatus){
        //system.assert(false , '>>>>>'+orderId + '>>>>' + orderStatus);
        processRecords(orderId , orderStatus);
    }
    @future
    public static void processRecords(Id orderId , String orderStatus)
    {
         system.debug('>>>>>>>StartTest');
         try{
             Order__c o = new order__c(id = orderId ,
                                        OrderStatus__c = orderStatus ,
                                        SentToVerificationBy2__c = UserInfo.getUserId()
                                        );
            update o;
            system.debug('>>>>>>>StopTest');
         }catch(exception e){
             system.debug('>>>>>>> Error'+ orderId + ', Exception message: '+e);
            //Order__c o = new order__c(id = orderId , Verification_Result__c =e.getMessage());
            //update o;
            
            //Prashant Gupta, Appirio, T-579230 2/21/17
                Order_Exception__c newOrderException = new Order_Exception__c();
                newOrderException.Order__c = orderId;
                newOrderException.Process__c = 'Verify Order';
                newOrderException.Exception__c = e.getMessage();
                insert newOrderException;
            //End
         }
    }
    
    

}