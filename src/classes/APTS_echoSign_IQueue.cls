public class APTS_echoSign_IQueue implements Queueable, Database.AllowsCallouts{
    private set<id> ProposalIDSet;  
    private set<id> OpportunitySet;
    
    public APTS_echoSign_IQueue(set<id> ParaSet)
    {
        this.ProposalIDSet = ParaSet;
        this.OpportunitySet  = ParaSet;
    }
    
    public void execute(QueueableContext context) { 
        system.debug('Queueable EXECUTE RUN');
        List<Opportunity> OppList = new list<Opportunity>();
        For(id TempId:OpportunitySet )
        {
        Opportunity opp = new Opportunity(Id=TempId,ReadyForProcessing__c=true,
                                                      StageName='Stage 4 - Won',Probability=90,IsValidationRequest__c=true,
                                                      Skip_Stage_Validation__c=true, OrderCreated__c = true, AutoCreateOrder__c = true);
            
            OppList.add(opp);
        }
        Update OppList;
        /*
        List<Opportunity> opptylist = new List<Opportunity>();
        MAP<id,Date> MAPAccountMSASigned = new MAP<id,Date>();
        List<Apttus_Proposal__Proposal__c> proplist = new List<Apttus_Proposal__Proposal__c>();
        Map<Id,Apttus_Proposal__Proposal__c>  proplmap = new  Map<Id,Apttus_Proposal__Proposal__c>(
            [select Id, signed_indicator__c, 
             Apttus_Proposal__Opportunity__c,
             Apttus_Proposal__Opportunity__r.echosign_indicator__c,
             MSA_checked__c, 
             Apttus_Proposal__Account__r.APTS_MSA_Status__c,
             Apttus_Proposal__Account__r.APTS_MSA_Start_Date__c
             from Apttus_Proposal__Proposal__c where Id in: ProposalIDSet]);
        
        for(Apttus_Proposal__Proposal__c eachechosign : proplmap.values()){
            Apttus_Proposal__Proposal__c proposal = eachechosign;  
            system.debug('proposal' + proposal);
            Opportunity oppty = eachechosign.Apttus_Proposal__Opportunity__r;
            system.debug('Opportunity:  '+oppty );
            if(oppty != null && !oppty.echosign_indicator__c){
                oppty.echosign_indicator__c = true;
                opptylist.add(oppty);  
            }
            system.debug('Apttus_Proposal__Proposal__c proposal :'+proposal );
            if(proposal != null && !proposal.signed_indicator__c ){
                proposal.signed_indicator__c = true;
                proposal.QuoteStatus__c = 'Accepted Online';
                proposal.QuoteStatus__c = 'Accepted Online';
                System.debug('MS Test111:'+proposal.MSA_checked__c);
                System.debug('MS Test112:'+proposal.Apttus_Proposal__Account__r.APTS_MSA_Status__c);
                
                If(proposal.MSA_checked__c && proposal.Apttus_Proposal__Account__r.APTS_MSA_Status__c!='Signed' &&  (!MAPAccountMSASigned.containsKey(proposal.Apttus_Proposal__Account__c)))
                {
                    MAPAccountMSASigned.put(proposal.Apttus_Proposal__Account__c,Date.today());
                }
                proplist.add(proposal);
            }
        }
        If(!MAPAccountMSASigned.isEmpty())
        {
            map<Id, Account> parentAccountMap = new map<Id, Account>([SELECT id, APTS_MSA_Status__c,APTS_MSA_Start_Date__c
                                                                      FROM Account 
                                                                      WHERE Id IN :MAPAccountMSASigned.keySet()]);
            
            System.debug('MS Test114:'+parentAccountMap);           
            for(id Tempid : parentAccountMap.keySet()){
                
                parentAccountMap.get(Tempid).APTS_MSA_Status__c = 'Signed';
                parentAccountMap.get(Tempid).APTS_MSA_Start_Date__c = Date.today();
            } 
            
            
            AccountTriggerHandler.ExecuteTriggers = false;
            update parentAccountMap.values();
        }
        if(!opptylist.isEmpty() && opptylist != null)
            update opptylist;
        if(!proplist.isEmpty() && proplist != null)
            update proplist;
        System.debug('MS Test113:'+MAPAccountMSASigned);
        
        */
        
    }
    
}