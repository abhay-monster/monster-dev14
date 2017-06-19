/*
** @author : Cloud Sherpas Inc.
** @date : 03/03/2014
** @description : base class for the "*Handler" classes that support triggers; it provides common read-only properties that help
              determine the context in which code is executing.
*/
global virtual with sharing class BaseTriggerHandler

{

    protected boolean TriggerIsExecuting = false;

    public boolean IsTriggerContext{
        get{ return TriggerIsExecuting;}
    }
    
    public boolean IsVisualforcePageContext{
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsWebServiceContext{
        get{ return !IsTriggerContext;}
    }
    
    public boolean IsExecuteAnonymousContext{
        get{ return !IsTriggerContext;}
    } 
    
    public static Boolean SkipOppUpdateToPreventRecursion = false;  // Used in OpportunityTriggerHandler
    
}