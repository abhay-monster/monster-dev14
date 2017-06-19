public with sharing class SalesCoachUtil {

        
    //this gets the opurtunity stages from OppurtunityStage which is set by user   
    public static SelectOption[] getOpptyStages(){
      SelectOption[] options = new SelectOption[] {};
      options.add( new SelectOption( '-- Select --', '-- Select --' ) );
      String[] oList = new String[] {};
      List<OpportunityStage> OS = [Select MasterLabel from OpportunityStage where IsActive=true order by SortOrder];
      for(OpportunityStage ml:OS)
       oList.add(ml.MasterLabel);
      for( string s : oList )
        options.add( new SelectOption( s.trim(), s.trim() ) );            
      return options;
    }
  
    //this is used to get all the fields from user that are picklists 
    //or strings   
    public static Map<String, Schema.SObjectField> getUserFieldsMap(){
      Map<String, Schema.SObjectField> fields = new Map<String, Schema.SObjectField>{};
      Map<String, Schema.SObjectField> M = Schema.SObjectType.User.fields.getMap();
      Set<String> uSet =M.keySet();
      Schema.DescribeFieldResult F;
      for(String s:uSet){
        F=M.get(s).getDescribe();
        if(F.getType()==Schema.Displaytype.STRING || F.getType()==Schema.Displaytype.PICKLIST){
          fields.put(s, M.get(s)); 
        }
      }
      return fields;
    }
    
    //this gets the opurtunity stages from OppurtunityStage which is set by user   
    public static String[] opptyStageList(){
    	String[] oList = new String[] {};
    	List<OpportunityStage> OS = [Select MasterLabel from OpportunityStage];
    	for(OpportunityStage ml:OS)
    	 oList.add(ml.MasterLabel);   	
    	return oList;
    }
    
 
}