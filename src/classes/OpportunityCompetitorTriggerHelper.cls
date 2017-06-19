//------------------------------------------------------------------------------------------------------------
//  Name: OpportunityCompetitorTriggerHelper
//  Date: 14/05/2015
//  Author: Gaurav (Appirio Ind.)
//  Purpose: Trigger handler helper for  handler OpportunityCompetitorTriggerHandler
//------------------------------------------------------------------------------------------------------------

public without sharing class OpportunityCompetitorTriggerHelper {
    
    final String CLASSNAME = '\n\n**** OpportunityCompetitorTriggerHelper.METHODNAME()';

    public static OpportunityCompetitorTriggerHelper NewTriggerHelper() {
        return  new OpportunityCompetitorTriggerHelper ();
    }
    /**
    * Method to Check for duplicate Opp Competitor Records
    * @params map<id,list<OpportunityCompetitor__c>> : Map of Opportunites and related Opportunity 
    *         list<OpportunityCompetitor__c> : List of related opportunity Ids
    */     
    public void recordDuplicateCheck(list<OpportunityCompetitor__c> lstNewOppCompetitor ,
                                     map<id,list<OpportunityCompetitor__c>> mapOppListOppComp){
        
        for(OpportunityCompetitor__c oppCompNew : lstNewOppCompetitor){
         if(mapOppListOppComp.containsKey(oppCompNew.Opportunity__c)){
            for(OpportunityCompetitor__c oppComp :mapOppListOppComp.get(oppCompNew.Opportunity__c) ){
                if(oppCompNew.Competitor__c == oppComp.Competitor__c && oppCompNew.Account_Country__c == oppComp.Account_Country__c){
                    oppCompNew.adderror('Records with duplicate combination of Account Country and Competitor on an opportunity can not be added.');
                }
            }
         }  
        }
        
    }    
     
    
   /**
    * Method to sync competitor records of both Opportunity and Account 
    * @params List<OpportunityCompetitor__c> : Newly inserted list of records
    *         Set<id> : List of related opportunity Ids
    */     
    public void syncOppCompWithRelatedAccComp(list<OpportunityCompetitor__c> lstNewOppCompetitor , Set<id> opportunityCompetitorOppsIds){       
        final string METHODNAME = CLASSNAME.replace('METHODNAME','syncOppCompWithRelatedAccComp');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        
        Set<id> oppAccountIds = new Set<id>();
        Map<id, List<CompetitiveLandscape__c>> mapIdListLandscape = new   Map<id, List<CompetitiveLandscape__c>>();
        

        
        Map<id,Opportunity> mapRelatedOpportunity = new Map<id,Opportunity>([select id , AccountId from opportunity where id IN:opportunityCompetitorOppsIds ]);
        
        for(Opportunity opp : mapRelatedOpportunity.values()){
            oppAccountIds.add(opp.AccountId);
        }
        
        List<CompetitiveLandscape__c> lstCompetitor = [select Account__c ,AccountCountry__c ,Competitor__c from CompetitiveLandscape__c where Account__c In :oppAccountIds];
        for(CompetitiveLandscape__c compOnAcc : lstCompetitor){
            if(!mapIdListLandscape.containskey(compOnAcc.Account__c))
                mapIdListLandscape.put(compOnAcc.Account__c , new list<CompetitiveLandscape__c>());
            mapIdListLandscape.get(compOnAcc.Account__c).add(compOnAcc);
        }
        
        Id accountIdOfOpportunityCompetitor;
        Boolean isInsert ;
        CompetitiveLandscape__c CompetitiveLandscape;
        list<CompetitiveLandscape__c> lstCompOnAccToInsert = new list<CompetitiveLandscape__c>();
        for(OpportunityCompetitor__c compOnOpp : lstNewOppCompetitor){
            accountIdOfOpportunityCompetitor = mapRelatedOpportunity.get(compOnOpp.Opportunity__c).AccountId;
            isInsert = true;
            if(mapIdListLandscape.containsKey(accountIdOfOpportunityCompetitor)){
                for(CompetitiveLandscape__c compOnAcc : mapIdListLandscape.get(accountIdOfOpportunityCompetitor)){              
                    if(compOnAcc.Competitor__c == compOnOpp.Competitor__c && compOnAcc.AccountCountry__c == compOnOpp.Account_Country__c){
                        isInsert=false;
                    }
                }
            }
            
            if(isInsert == true){
                CompetitiveLandscape = new CompetitiveLandscape__c();
                CompetitiveLandscape.Account__c = accountIdOfOpportunityCompetitor;
                if(compOnOpp.Competitor__c != null)
                    CompetitiveLandscape.Competitor__c = compOnOpp.Competitor__c;
                if(compOnOpp.Account_Country__c != null)
                    CompetitiveLandscape.AccountCountry__c = compOnOpp.Account_Country__c;
                if(compOnOpp.LegacyKarmaID__c != null)
                    CompetitiveLandscape.LegacyKarmaID__c = compOnOpp.LegacyKarmaID__c;                 
                lstCompOnAccToInsert.add(CompetitiveLandscape);
            }
        }
        
        try{  
          if(lstCompOnAccToInsert.size()  > 0)
          insert lstCompOnAccToInsert;              
        }catch(BaseApplicationException bae){
            throw bae;
        }
        catch(Exception ex){
            throw BaseApplicationException.NewExceptionWithInnerException(METHODNAME, 'A problem has occurred & processing cannot complete successfully - please see system log for details. ' + ex.getMessage() + ex.getLineNumber(), ex);
        }        
         
    }  
    
}