/*
** @author : Apprio.
** @date : 
** @description :
*/
public with sharing class ExternalLinksController {

    public List<Reporting_Links__c> ExternalLIst {get;set;}
    public List<Reporting_Links__c> InternalLIst {get;set;}
    
  
    public ExternalLinksController(ApexPages.StandardController controller){
    ExternalLIst  = new List<Reporting_Links__c>();
    InternalLIst  = new List<Reporting_Links__c>();
           for(Reporting_Links__c rl : Reporting_Links__c.getAll().values())
    {
            if(rl.External_to_SFDC__c == true){
            system.debug('Check *****' + rl);
                    ExternalLIst.add(rl);
            }
            else{
                    InternalLIst.add(rl);
            }
            system.debug('Check ********' +ExternalLIst);
            system.debug('Check ********' +InternalLIst);

    }
    }
    
  /*  public List<List<Reporting_Links__c>> getIntLink(List<Reporting_Links__c> internallink){
          List<Reporting_Links__c> tempintLink;
          List<List<Reporting_Links__c>> doubleintLink = new List<List<Reporting_Links__c>>();
          for(List<Reporting_Links__c> intelink : internallink){
              tempintLink = new List<Reporting_Links__c>();
              for(Integer a=0;a<4;a++){
                  tempintLink.add(intelink);
              }
              doubleintLink.add(tempintLink);
              
          }
          return doubleintLink;
    } */
    
}