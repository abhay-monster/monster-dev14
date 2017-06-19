@isTest
public class TriggerStateTest{
    static testMethod void testLeadTrigger(){
        Map<String, TriggerSettings__c> triggerSetting = TriggerSettings__c.getAll();
    
        TriggerState.isActive('DummyTrigger');
        
        triggerSetting = TriggerSettings__c.getAll();
        
        TriggerSettings__c ts = triggerSetting.get('DummyTrigger');
        ts.isActive__c = false;
        ts.isTestMode__c = true;
        
        update ts;
        
        TriggerState.isActive('LeadTrigger');
        TriggerState.executeForTestMethods('LeadTrigger');
    }
}