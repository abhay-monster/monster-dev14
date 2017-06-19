public with sharing class ClearQuestCC {
    String country = null;
    public String CQNumber{get;set;}
    public monsterBizappsClearquestWebservice.MultiTicketInfoResponse ProjectList{get;set;}  
    public List<CQWrapper> ProjectListToDisplay {get;set;} 
    public List<String> ExternalTicketsList {get;set;}
    private Id caseId{get;set;}
    public ClearQuestCC(ApexPages.StandardController controller){
        ExternalTicketsList = new List<String>();
        try{
            caseId = ApexPages.currentPage().getParameters().get('caseId');
            for(ExternalTicket__c et :[SELECT Id, Name, SourceSystem__c FROM ExternalTicket__c WHERE SourceSystem__c =: 'Clearquest' AND Case__c =: caseId]){
                ExternalTicketsList.add(et.Name);           
            }
            ProjectListToDisplay = new List<CQWrapper>();
            monsterBizappsClearquestWebservice.ClearQuestService cqmcq = new monsterBizappsClearquestWebservice.ClearQuestService();
            if(ExternalTicketsList.size()==1){
                ProjectListToDisplay.add(new CQWrapper(cqmcq.GetCQTicket(ExternalTicketsList[0]).ErrorMessage,cqmcq.GetCQTicket(ExternalTicketsList[0]).Project, cqmcq.GetCQTicket(ExternalTicketsList[0]).State, cqmcq.GetCQTicket(ExternalTicketsList[0]).SubProject, cqmcq.GetCQTicket(ExternalTicketsList[0]).EstimateDate, cqmcq.GetCQTicket(ExternalTicketsList[0]).ErrorStatus, cqmcq.GetCQTicket(ExternalTicketsList[0]).ID ));
            }else if(ExternalTicketsList.size()>1){
                schemasMicrosoftCom200310Serializat2.ArrayOfstring myList = new schemasMicrosoftCom200310Serializat2.ArrayOfstring();
                myList.string_x = ExternalTicketsList;
                ProjectList = cqmcq.GetMultipleCQTicket(myList);
                for( monsterBizappsClearquestWebservice.TicketInfoResponse  s : ProjectList.TicketsInfo.TicketInfoResponse){
                    ProjectListToDisplay.add(new CQWrapper(s.ErrorMessage, s.Project, s.State, s.SubProject, s.EstimateDate, s.errorStatus, s.Id ));
                }
            }
        }catch(Exception e){
            ApexPages.addMessages(e);
        }
    }
    public class CQWrapper{
        public String ErrorMessage{get;set;}
        public String Project{get;set;}
        public String State{get;set;}
        public String SubProject{get;set;}
        public String projectId{get;set;}
        public DateTime estimatedDate{get;set;}
        public Integer errorStatus{get;set;} 
        public CQWrapper( String ErrorMessage, String Project, String State, String SubProject, DateTime estimatedDate, Integer errorStatus, String projectId ){
             this.ErrorMessage = ErrorMessage;
              this.Project = Project;
              this.State =State;
              this.SubProject =SubProject;
              this.projectId =projectId;
              this.estimatedDate =estimatedDate;
              this.errorStatus =errorStatus;
        }
    } 
}