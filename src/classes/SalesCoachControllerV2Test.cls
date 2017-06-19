/**

 */
@isTest
private class SalesCoachControllerV2Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
    }
    
     //test of updateStageData
  private static testmethod void testUpdateStageData(){
    TestingUtil tu = new TestingUtil();
    SalesCoachControllerV2 scc = new SalesCoachControllerV2();
    System.assert(scc.updateStageData()==null);
    
  }
  
  //test of SelectOption
  private static testmethod void testSelectOption(){
  	TestingUtil tu = new TestingUtil();
  	SalesCoachControllerV2 scc = new SalesCoachControllerV2();
  	System.assert(scc.getOpptyStages().size()>0);
  	
  }
  
   //testing constructor and methods it calls
   private static testmethod void testConstructor(){
    	SalesCoachControllerV2 sccExceptions = new SalesCoachControllerV2();
      sccExceptions.startProcess();  
     // sccExceptions.populateSuperSections();  
     // sccExceptions.populateActivities();
       
      TestingUtil tu = new TestingUtil();
      SalesCoachControllerV2 scc = new SalesCoachControllerV2();
     
    }
    
       //test getters and setters
    //test of updateStageData
  private static testmethod void testGettersAndSetters(){
    TestingUtil tu = new TestingUtil();
    SalesCoachControllerV2 scc = new SalesCoachControllerV2();
    System.assert(scc.getOpportunityStage()=='testStage');
    System.assert(scc.getSalesCoachStage().Name=='testStage');
    System.assert(scc.getSuperSections().size()>=0);
    System.assert(scc.getSalesCoachActivities().size()>0);
    System.assert(scc.getSuperSections()[0].getSalesCoachSection()!=null);
    System.assert(scc.getSuperSections()[0].getSalesCoachSectionItems().size()>0);
    
    scc.setOpportunityStage('newOpStage');
    System.assert(scc.getOpportunityStage()=='newOpStage');
  }
}