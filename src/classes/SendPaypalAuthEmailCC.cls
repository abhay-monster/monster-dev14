public without sharing class SendPaypalAuthEmailCC {
    private Id OrderId;
    private Id InvoiceId;
    private Id proposalId;
    public Apttus_Proposal__Proposal__c usedProposal {get; private set;}
    public Order__c usedOrder {get; private set;}
    public Invoices__c usedInvoice {get; private set;}
    
    public String Message {get; set;}
    public boolean IsOrder{get; set;}
    public boolean IsInvoice {get; set;}
    public boolean IsProposal {get; set;}
    private Boolean isPreped;
    
    public SendPaypalAuthEmailCC(){
        system.debug('\n\n Calling SendPaypalAuthEmailCC.constructor \n\n');

        IsOrder = false;
        IsInvoice = false;
        IsProposal = false;

        
        if(ApexPages.currentPage().getParameters().containsKey('Id')) {
            IsInvoice = true;
            InvoiceId = ApexPages.currentPage().getParameters().get('Id');
        }
         if(ApexPages.currentPage().getParameters().containsKey('OrderId')) {
            IsOrder = true;
            OrderId = ApexPages.currentPage().getParameters().get('OrderId');
        }
        if(ApexPages.currentPage().getParameters().containsKey('ProposalId')) {
            IsProposal = true;
            proposalId = ApexPages.currentPage().getParameters().get('ProposalId');
        } 

        Message = '';
        isPreped = false;
        if(InvoiceId  == null && OrderId == null && proposalId == null){
            Message = 'Invalid Parameter.';
        }else{

            if(IsInvoice) {            
                usedInvoice = [SELECT Id, IsPaypalAuthorizationEmailSent__c, Order__r.billingContact__c FROM Invoices__c WHERE Id = :InvoiceId ];
            }
            else if(IsOrder){
                usedOrder = [SELECT Id, IsPaypalAuthorizationEmailSent__c, billingContact__c FROM Order__c WHERE Id = :OrderId];
            }
            else if(IsProposal){
                usedProposal = [SELECT Id, Is_Paypal_Authorization_Email_Sent__c, BillContact__c  FROM Apttus_Proposal__Proposal__c WHERE Id = :proposalId];
            }
        }
    }
    
    public void prepSendEmail(){
       
            if(IsInvoice && usedInvoice!= null && usedInvoice.IsPaypalAuthorizationEmailSent__c){

                usedInvoice.IsPaypalAuthorizationEmailSent__c = false;
                isPreped = true;
                Message = 'sendEmail';
            }
            else if(IsOrder && usedOrder!= null && usedOrder.IsPaypalAuthorizationEmailSent__c){

                usedOrder.IsPaypalAuthorizationEmailSent__c = false;
                isPreped = true;
                Message = 'sendEmail';
            }
            else if(IsProposal && usedProposal!= null && usedProposal.Is_Paypal_Authorization_Email_Sent__c){

                usedProposal.Is_Paypal_Authorization_Email_Sent__c = false;
                isPreped = true;
                Message = 'sendEmail';
            }             
        
    }
    
    public void sendEmail(){
        system.debug('\n\n Calling SendPaypalAuthEmailCC.sendEmail \n\n');
        try{
            if(IsInvoice && usedInvoice != null && !usedInvoice.IsPaypalAuthorizationEmailSent__c){
                if(isPreped){
                    usedInvoice.IsPaypalAuthorizationEmailSent__c = false;
                    //usedOrder.IsPaypalAuthorizationEmailSent__c = false;
                    usedInvoice.billingContact__c = usedInvoice.Order__r.billingContact__c ;
                    OrderTriggerHandler.ExecuteTriggers = false;
                    //update usedOrder;
                    update usedInvoice;
                }
                usedInvoice.IsPaypalAuthorizationEmailSent__c = true;
                //usedOrder.IsPaypalAuthorizationEmailSent__c = true;
                usedInvoice.billingContact__c = usedInvoice.Order__r.billingContact__c ;
               // OrderTriggerHandler.ExecuteTriggers = false;
                //update usedOrder;
                update usedInvoice;
                Message = 'Email sent.';
            }

            else if(IsOrder && usedOrder != null && !usedOrder.IsPaypalAuthorizationEmailSent__c){
                if(isPreped){                   
                    usedOrder.IsPaypalAuthorizationEmailSent__c = false;                   
                    OrderTriggerHandler.ExecuteTriggers = false;
                    update usedOrder;                   
                }                
                usedOrder.IsPaypalAuthorizationEmailSent__c = true;               
                OrderTriggerHandler.ExecuteTriggers = false;
                update usedOrder;               
                Message = 'Email sent.';
            }

            else if(IsProposal && usedProposal != null && !usedProposal.Is_Paypal_Authorization_Email_Sent__c){
                if(isPreped){                   
                    usedProposal.Is_Paypal_Authorization_Email_Sent__c = false;                   
                    ApttusProposalTriggerHandler.ExecuteTriggers = false;
                    update usedProposal;                   
                }                
                usedProposal.Is_Paypal_Authorization_Email_Sent__c = true;               
                ApttusProposalTriggerHandler.ExecuteTriggers = false;
                update usedProposal;               
                Message = 'Email sent.';
            }
            
        }catch(Exception e){
            system.debug('\n\nError: ' + e + '\n\n');
            Message = 'An error occured.';
        }
    } 
}



/* Old Code commented out

public without sharing class SendPaypalAuthEmailCC {
    private Id OrderId;
    private Id InvoiceId;
    public Order__c usedOrder {get; private set;}
    public Invoices__c usedInvoice {get; private set;}
    
    public String Message {get; set;}
    private Boolean isPreped;
    
    public SendPaypalAuthEmailCC(){
        system.debug('\n\n Calling SendPaypalAuthEmailCC.constructor \n\n');
        
        InvoiceId = ApexPages.currentPage().getParameters().get('Id');
        
        Message = '';
        isPreped = false;
        if(InvoiceId  == null){
            Message = 'Invalid Parameter.';
        }else{
            
            usedInvoice = [SELECT Id, Order__r.IsPaypalAuthorizationEmailSent__c FROM Invoices__c WHERE Id = :InvoiceId ];
            usedOrder = [SELECT Id, IsPaypalAuthorizationEmailSent__c, billingContact__c FROM Order__c WHERE Id = :usedInvoice.Order__c];
        }
    }
    
    public void prepSendEmail(){
        system.debug('\n\n Calling SendPaypalAuthEmailCC.prepSendEmail \n\n');
        try{
            if(usedInvoice!= null && usedInvoice.Order__r.IsPaypalAuthorizationEmailSent__c){
                usedOrder.IsPaypalAuthorizationEmailSent__c = false;
                isPreped = true;
                Message = 'sendEmail';
            }
            system.debug('\n\nprep: ' + usedInvoice.Order__r.IsPaypalAuthorizationEmailSent__c + '\n\n');
        }catch(Exception e){
            system.debug('\n\nError: ' + e + '\n\n');
            Message = 'An error occured.';
        }
    }
    
    public void sendEmail(){
        system.debug('\n\n Calling SendPaypalAuthEmailCC.sendEmail \n\n');
        try{
            if(usedOrder != null && !usedOrder.IsPaypalAuthorizationEmailSent__c){
                if(isPreped){
                    usedInvoice.IsPaypalAuthorizationEmailSent__c = false;
                    usedOrder.IsPaypalAuthorizationEmailSent__c = false;
                    usedInvoice.billingContact__c = usedOrder.billingContact__c ;
                    OrderTriggerHandler.ExecuteTriggers = false;
                    update usedOrder;
                    update usedInvoice;
                }
                usedInvoice.IsPaypalAuthorizationEmailSent__c = true;
                usedOrder.IsPaypalAuthorizationEmailSent__c = true;
                usedInvoice.billingContact__c = usedOrder.billingContact__c ;
                OrderTriggerHandler.ExecuteTriggers = false;
                update usedOrder;
                update usedInvoice;
                Message = 'Email sent.';
            }
            system.debug('\n\nsend: ' + usedOrder.IsPaypalAuthorizationEmailSent__c + '\n\n');
        }catch(Exception e){
            system.debug('\n\nError: ' + e + '\n\n');
            Message = 'An error occured.';
        }
    } 
}

*/