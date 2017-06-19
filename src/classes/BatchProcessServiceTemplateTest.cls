@isTest
private class BatchProcessServiceTemplateTest{

 static testMethod void batchProcess(){
 
    Account a= new account(name='test',billingcountry='india');
    try{
        insert a;
    }catch(Exception e){
            system.assert(false,'Account not created');
    }
     List<Sobject> sObjectLst = new List<Sobject>{a}; 
     String queryString = 'SELECT Name FROM Account LIMIT 100' ;
     Test.StartTest();
     BatchProcessServiceTemplate batch  = new BatchProcessServiceTemplate ();
     batch.GetQuery();
     batch.ProcessBatch(sObjectLst);
     batch.GetQueryLocator(queryString);
     batch.FinishBatch();
     Test.stopTest();
 
 }
}