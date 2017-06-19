//------------------------------------------------------------------------------------------------------------
//  Name: OpportunityCompetitorTriggerHandler
//  Date: 14/05/2015
//  Author: Gaurav (Appirio Ind.)
//  Purpose: Trigger handler for  OpportunityCompetitor__c Object.
//------------------------------------------------------------------------------------------------------------
public without sharing class OpportunityCompetitorTriggerHandler extends BaseTriggerHandler{
    final String CLASSNAME = '\n\n**** OpportunityCompetitorTriggerHandler.METHODNAME()';
    private OpportunityCompetitorTriggerHelper opportunityCompetitorHelper ;
    
   /**
    * Constructor of trigger handler than initializes helper class
    * @return PageReference
    */  
    public OpportunityCompetitorTriggerHandler(boolean isExecuting){
        
        // trigger is executing
        TriggerIsExecuting = isExecuting;
         opportunityCompetitorHelper = OpportunityCompetitorTriggerHelper.NewTriggerHelper();         
        /*
            note - developer may want to create new or extent the base helper class specific to an sObject (i.e. OpportunityCompetitorTriggerHandler)
        */
    }
   /**
    * before insert method for Object OpportunityCompetitor__c
    * @params lstNewOppCompetitor : Newly inserted list of records
    */     
    public void beforeInsert(list<OpportunityCompetitor__c> lstNewOppCompetitor){
    	Set<id> opportunityCompetitorOppsIds = new Set<id>(); 
        for(OpportunityCompetitor__c oppComp : lstNewOppCompetitor){
        	opportunityCompetitorOppsIds.add(oppComp.Opportunity__c);
        }       

		list<OpportunityCompetitor__c> lstOppComp = [Select Opportunity__c , 
															Account_Country__c,Competitor__c 
													from OpportunityCompetitor__c 
													where  Opportunity__c 
													IN :opportunityCompetitorOppsIds ];	
		map<id,list<OpportunityCompetitor__c>> mapOppListOppComp = new map<id,list<OpportunityCompetitor__c>>();
		for(OpportunityCompetitor__c oppComp : lstOppComp){
			if(!mapOppListOppComp.containskey(oppComp.Opportunity__c))
				mapOppListOppComp.put(oppComp.Opportunity__c , new list<OpportunityCompetitor__c>());			
			mapOppListOppComp.get(oppComp.Opportunity__c).add(oppComp);		
		}
		
		//Opp Competitor Record Duplicate Check 
		opportunityCompetitorHelper.recordDuplicateCheck(lstNewOppCompetitor ,mapOppListOppComp );		
    	
    }    
    
    
   /**
    * after insert method for Object OpportunityCompetitor__c
    * @params lstNewOppCompetitor : Newly inserted list of records
    */     
    public void afterInsert(List<OpportunityCompetitor__c> lstNewOppCompetitor){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','afterInsert');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
    	
    	Set<id> opportunityCompetitorOppsIds = new Set<id>(); 
        for(OpportunityCompetitor__c oppComp : lstNewOppCompetitor){
        	opportunityCompetitorOppsIds.add(oppComp.Opportunity__c);
        }       
        	if(IsTriggerContext && (!IsVisualforcePageContext && !IsWebServiceContext && !IsExecuteAnonymousContext)){       		
				opportunityCompetitorHelper.syncOppCompWithRelatedAccComp(lstNewOppCompetitor , opportunityCompetitorOppsIds);            	
			}
    }
    

}