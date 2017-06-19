/**
* @author Original: Cloud Sherpas, Inc.
* @date   Original: 19 DEC 2014
* @description controller class referenced by related list link that deletes the matching account and program in the account to program object.
* @History - 19 DEC 2014 - cloud sherpas - created
*/   
public without sharing class RemoveAccountToProgramCC {  
    public string Message {get;set;}
    
    public PageReference removeAccountToProgram(){
        
        final String CLASSNAME = '\n\n**** RemoveAccountToProgram.METHODNAME()';
        final string METHODNAME = CLASSNAME.replace('METHODNAME','removeAccountToProgram');
        Logger.push(METHODNAME, Schema.AccountProgram__c.getSObjectType().getDescribe().getName());
        
        try{                      
            string accId = ApexPages.currentPage().getParameters().get('accId');
            string prgId = ApexPages.currentPage().getParameters().get('prgId');
            
            //message for success and error handling
            Message = '';
        
            list<Account> updAccList = new list<Account>();
            //retrieve all account to program records matching the submitted account and program id.
            for(Account acc :[select id, AccountProgram__c 
                                from Account 
                                where Id=:accId]){
                acc.AccountProgram__c = null;
                updAccList.add(acc);    
            } 
            //update account to remove the relationship to program
            update updAccList;
            Message = Label.CS_RemoveAccToProg_SuccessMessage;
            return new PageReference('/' + prgId);
        }        
        catch(exception e){
            Logger.debugException(Label.CS_RemoveAccToProg_ErrorMessage + '\n ' +e.getMessage());
            Logger.pop();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CS_RemoveAccToProg_ErrorMessage + '\n ' +e.getMessage())); 
        }
        return null;
    } 
}