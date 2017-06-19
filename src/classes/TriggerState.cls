/***************************************************************************
// (c) 2013 Appirio, Inc.
//
// Description    : Class that returns the state of a given trigger and
//                : if it should execute when test methods are executed
//                  
// Sep 12, 2013   : Randy Wandell   Original  
//   
//***************************************************************************/
public abstract class TriggerState {
    static Map<String, TriggerSettings__c> triggerSetting = TriggerSettings__c.getAll();
    
    public static boolean isActive(String triggerName) {
        boolean isActive = true;
        try {
            if(triggerSetting.containsKey(triggerName)) {
                isActive = (Boolean)triggerSetting.get(triggerName).get('isActive__c');
                if(Test.isRunningTest()) { isActive = executeForTestMethods(triggerName); }
            } else {
                addTriggerToSettings(triggerName);
            }
        } catch (Exception e) {
        }
        return isActive;
    }
    
    public static boolean executeForTestMethods(String triggerName) {
        boolean isTestMode = true;
        if(Test.isRunningTest()) {
            try {
                if(triggerSetting.containsKey(triggerName)) {
                    isTestMode = (Boolean)triggerSetting.get(triggerName).get('isTestMode__c');
                }
            } catch (Exception e) {
            }
        }
        return isTestMode ;
    }
    
    private static void addTriggerToSettings(String triggerName) {
        TriggerSettings__c triggerSettings = new TriggerSettings__c();
        triggerSettings.Name = triggerName;
        triggerSettings.isActive__c = true;
        triggerSettings.isTestMode__c = true;
                
        insert triggerSettings;
        
        triggerSetting = TriggerSettings__c.getAll();           
    }
}