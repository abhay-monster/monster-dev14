public with sharing class SalesCoachControllerV2 {

    private Opportunity oppty;
    private List<String> salesCoachProducts;
    private String opportunityStage;
    private Sales_Coach_Stage__c salesCoachStage;    
    private List<SuperSection> superSections;
    private List<Sales_Coach_Activity__c> salesCoachActivities;
    public Boolean renderCheck                                      {get; set;  }
    public String getOpportunityStage()                             {return this.opportunityStage;}
    public Sales_Coach_Stage__c getSalesCoachStage()                {return this.salesCoachStage;}
    public List<SuperSection> getSuperSections()                    {return this.superSections;}
    public List<Sales_Coach_Activity__c> getSalesCoachActivities()  {return this.salesCoachActivities;}
    public void setOpportunityStage(String pStage)                  {this.opportunityStage = pStage;}
    
 
  
  public SalesCoachControllerV2() {
       String ID = ApexPages.currentPage().getParameters().get('id');
      try{ 
        this.oppty = [select id, 
                     StageName, 
                     forecastcategory
                      from Opportunity 
                        where id= :ID];        
          this.opportunityStage = this.oppty.StageName;
          startProcess();
        }catch(QueryException e){
          ApexPages.addMessages(e);
        }
    }
    
    
    public void startProcess(){
        populateSalesCoachStage();        
        if(this.salesCoachStage != null){
          populateSuperSections();
          populateActivities();
          if(this.salesCoachActivities.size() >0 && this.superSections.size()>0)
           this.renderCheck = true;
          else
           this.renderCheck = false;
        }
    }

    
    private void populateSalesCoachStage(){
      try{
          this.salesCoachStage = [select  
                         Name, 
                         Id, 
                         Buyer_Stage__c, 
                         Active__c 
                                  from Sales_Coach_Stage__c
                                  where Name = : this.opportunityStage Limit 1];
                                  
      }catch(QueryException e){
        this.salesCoachStage=null;
      }
    }
    
    private void populateSuperSections(){
      this.superSections = new List<SuperSection>();
    try{
         List<Sales_Coach_Section__c> sList = [select Section_Ordering__c, 
                                 Section_Name__c, 
                                 Sales_Coach_Stage__c, 
                                 Name, 
                                 Id,
                                 Sales_Coach_Section__c.Sales_Coach_Stage__r.Name, 
                                 Section_Width__c,
                                 (select Section_Ordering__c, 
                                     Sales_Coach_Section__c, 
                                     Name, 
                                     Link_to_Content__c, 
                                     Item_Name__c, 
                                     Id, 
                                     Display__c, 
                                     Products__c 
                                              from Sales_Coach_Section_Items__r
                                              order by Section_Ordering__c)  
                                                  from Sales_Coach_Section__c
                                                  where Sales_Coach_Stage__c = :this.salesCoachStage.Id
                                                  order by Section_Ordering__c];
                                                  
      for(Sales_Coach_Section__c section : sList){
        if(section.Sales_Coach_section_Items__r.isEmpty()){
          this.superSections.add(new SuperSection(section, null));
        }else{
          this.superSections.add(new SuperSection(section, section.Sales_Coach_section_Items__r));
        }
      }
      }catch(Exception e){
      ApexPages.addMessages(e );    
      }
    }
    
    private void populateActivities(){
        try{
          this.salesCoachActivities = [select Sales_Coach_Stage__c, 
                            Ordering_Number__c, 
                            Name, 
                            Id, 
                            Activity_Details__c 
                         from Sales_Coach_Activity__c
                         where Sales_Coach_Stage__c = : this.salesCoachStage.Id
                         order by Ordering_Number__c];
         
        }catch(Exception e){
      ApexPages.addMessages(e );    
      }
    }

  

    public SelectOption[] getOpptyStages() {
        List<SelectOption> op = SalesCoachUtil.getOpptyStages();
        if(op.size()>0)
          op.remove(0);
        return op;
    }
  
  
  
  public PageReference updateStageData() {
      startProcess();
        return null;
    }
  
 
   
  class SuperSection {
    
      private Sales_Coach_Section__c salesCoachSection;
      private List<Sales_Coach_Section_Item__c> salesCoachSectionItems;
      
      public Sales_Coach_Section__c getSalesCoachSection(){return salesCoachSection;}
      public List<Sales_Coach_Section_Item__c> getSalesCoachSectionItems(){return salesCoachSectionItems;}
      
      public SuperSection(Sales_Coach_Section__c pSec, List<Sales_Coach_Section_Item__c> pItems) {
          salesCoachSection = pSec;
          salesCoachSectionItems = pItems;
        }
    }
    
    
}