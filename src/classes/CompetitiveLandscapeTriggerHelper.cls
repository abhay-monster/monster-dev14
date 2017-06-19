/*
** @author : Cloud Sherpas Inc. 
** @date : 04/03/2014
** @description :   class that supports the '*TriggerHandler' class; it provides the methods called from those classes
*/
public with sharing class CompetitiveLandscapeTriggerHelper
{ 
    final String CLASSNAME = '\n\n**** CompetitiveLandscapeTriggerHelper.METHODNAME()';
    
    // ********* PROPERTIES ***********
    private String UserProfileName{get; private set;}

/*
** @author : Cloud Sherpas Inc.
** @date : 04/03/2014
** @description : static method that instantiates a new instance of the class & sets the user's profile name member variable
** @paramaters : a string - the profile name for the current user
** @returns : a new instance of the CompetitiveLandscapeTriggerHelper class
*/
    public static CompetitiveLandscapeTriggerHelper NewTriggerHelper(String pUserProfileName){
        
        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        CompetitiveLandscapeTriggerHelper newHelper = new CompetitiveLandscapeTriggerHelper(pUserProfileName);
        return newHelper;
    }
    
/*
** @author : Cloud Sherpas Inc.
** @date : 04/03/2014
** @description : static method that instantiates a new instance of the class
** @paramaters : nothing
** @returns : a new instance of the CompetitiveLandscapeTriggerHelper class
*/
    public static CompetitiveLandscapeTriggerHelper NewTriggerHelper(){
        
        //final string METHODNAME = CLASSNAME.replace('METHODNAME','NewTriggerHelper');
        //system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        CompetitiveLandscapeTriggerHelper newHelper = new CompetitiveLandscapeTriggerHelper('');
        return newHelper;
    }

/*
** @author : Cloud Sherpas, Inc.
** @date : 04/03/2014
** @description : this method is the class constructor
** @paramaters : none
** @returns : nothing
*/
    private CompetitiveLandscapeTriggerHelper(String pUserProfileName){  
        
        final string METHODNAME = CLASSNAME.replace('METHODNAME','CompetitiveLandscapeTriggerHelper');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        
        UserProfileName = pUserProfileName;
    } 
}