public class SandboxBuildHelper {
    
    final String CLASSNAME = '\n\n**** SandboxBuild.METHODNAME()';
    private static String siteURL = 'http://dev-monster.cs21.force.com';
    private static  String str_baseURL = Url.getSalesforceBaseUrl().toExternalForm();
    
       
    public void updateApttusURLs()
    {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateApttusURLs');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));

        System.debug('Base URL is:'+str_baseURL);
        // Update Org Setting
            
        Org_Settings__c orgSettings = Org_Settings__c.getOrgDefaults();
        if (orgSettings != null) {
            System.debug('product URL is:'+ orgSettings.Product_URL__c);
            orgSettings.Product_URL__c = str_baseURL;
            System.debug('product URL after update is:'+ orgSettings.Product_URL__c);
            update orgSettings;
    	}
        
        Map<String,Apttus_Approval__ApprovalsSystemProperties__c> approvalMap = Apttus_Approval__ApprovalsSystemProperties__c.getAll();
        if (approvalMap != null) {
            Apttus_Approval__ApprovalsSystemProperties__c approvalConfig = approvalMap.get('System Properties');
            System.debug('approval URL before update is:'+ approvalConfig.Apttus_Approval__InstanceUrl__c);
            approvalConfig.Apttus_Approval__InstanceUrl__c = str_baseURL;
            System.debug('approval URL after update is:'+ approvalConfig.Apttus_Approval__InstanceUrl__c);
            update approvalConfig;
        }
        
        Apttus_Config2__ConfigSystemProperties__c apttusConfig = Apttus_Config2__ConfigSystemProperties__c.getValues('System Properties');
        if (apttusConfig != null)
        {
           System.debug('Apptus Config System Properties before update:'+ apttusConfig.Apttus_Config2__InstanceUrl__c); 
           apttusConfig.Apttus_Config2__InstanceUrl__c  = str_baseURL;
            System.debug('Apptus Config System Properties after update:'+ apttusConfig.Apttus_Config2__InstanceUrl__c);
            update apttusConfig;
        }

    } // end update Apttus configs
    
    public void updateEmails()
    {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateEmails');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        // Update Queue Emails
        List<Group> groupEmails = [SELECT Email,Id FROM Group where email != null];
        if (groupEmails != null) {
            List<Group> listToUpdate = new List<Group>();
            for (Group item : groupEmails) {
                    item.Email = item.Email.replace('@','=');
                    item.Email = item.Email + '@example.com';    
                    System.debug('group emails after: '+ item.Email);
                    listToUpdate.add(item);
                }
            if (listToUpdate != null && listToUpdate.size() > 0) 
               update listToUpdate;
            System.debug('Group emails size: '+ listToUpdate.size());
        }
        
    }
    
    public void updateEmailtoCase()
    {
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateEmailtoCase');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        // Change all Active rules to Debug
        List<CaseRoutingRule__c> routingRules = [SELECT id, Routing_Status__c
                                           FROM CaseRoutingRule__c
                                           WHERE Routing_Status__c = 'Active'];
        if (routingRules != null && routingRules.size() > 0) {
            List<CaseRoutingRule__c> ruleUpdateList = new List<CaseRoutingRule__c>();
            for (CaseRoutingRule__c item : routingRules) {
                    item.Routing_Status__c = 'Debug';
                    ruleUpdateList.add(item);
                }
            update ruleUpdateList;
            System.debug('Number of routing rules active: '+routingRules.size());
        } // end if
    }

    public void updateTaxNowSettings(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateTaxNowSettings');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        // update TaxNowSettings for Avalara
        AVA_SFCORE__TaxNowSetting__c taxSettings = [Select AVA_SFCORE__Account_Number__c, AVA_SFCORE__License_Key__c,
                                                   AVA_SFCORE__Service_URL__c from AVA_SFCORE__TaxNowSetting__c limit 1];
        taxSettings.AVA_SFCORE__Service_URL__c  = 'https://development.avalara.net/';
        taxSettings.AVA_SFCORE__Account_Number__c  = '1100145554';
        taxSettings.AVA_SFCORE__License_Key__c  = 'E48F06C39A71A1A3';
        System.debug('accountnum: '+taxSettings.AVA_SFCORE__Account_Number__c);
        System.debug('license key: '+taxSettings.AVA_SFCORE__License_Key__c);
        update taxSettings;
    }

    public void updateIntegrationSettings(){
        final string METHODNAME = CLASSNAME.replace('METHODNAME','updateIntegrationSettings');
        system.debug(LoggingLevel.INFO, METHODNAME.replace('**** ', '**** Inside '));
        //test updating a custom setting
        Map<String,IntegrationConfig__c> iConfigMap = IntegrationConfig__c.getAll();
        List<IntegrationConfig__c> iConfigToUpdate = new List<IntegrationConfig__c>();

        //Avalara integration update
        IntegrationConfig__c avaConfig = iConfigMap.get('Avalara Integration');
        if(avaConfig != null){
            avaConfig.EndpointName__c = 'AvalaraDev';
            iConfigToUpdate.add(avaConfig);
        }

        //Paypal integration update
        IntegrationConfig__c payConfig = iConfigMap.get('Paypal US');
        if(payConfig != null){
            payConfig.EndpointName__c = 'Payflow-pilot';
            iConfigToUpdate.add(payConfig);
        }

        IntegrationConfig__c payConfig1 = iConfigMap.get('Paypal CA - USD');
        if(payConfig1 != null){
            payConfig1.EndpointName__c = 'Payflow-pilot';
            iConfigToUpdate.add(payConfig1);
        }

        IntegrationConfig__c payConfig2 = iConfigMap.get('Paypal CA - CAD');
        if(payConfig2 != null){
            payConfig2.EndpointName__c = 'Payflow-pilot';
            iConfigToUpdate.add(payConfig2);
        }

        IntegrationConfig__c payConfig3 = iConfigMap.get('Invoice - Paypal US - USD');
        if(payConfig3 != null){
            payConfig3.EndpointName__c = 'Payflow-pilot';
            iConfigToUpdate.add(payConfig3);
        }

        IntegrationConfig__c payConfig4 = iConfigMap.get('Invoice - Paypal CA - USD');
        if(payConfig4 != null){
            payConfig4.EndpointName__c = 'Payflow-pilot';
            iConfigToUpdate.add(payConfig4);
        }

        IntegrationConfig__c payConfig5 = iConfigMap.get('Invoice - Paypal CA - CAD');
        if(payConfig5 != null){
            payConfig5.EndpointName__c = 'Payflow-pilot';
            iConfigToUpdate.add(payConfig5);
        }
        
        //Site Integration update
        IntegrationConfig__c siteConfig = iConfigMap.get('Site Integration');
        if(siteConfig != null){
            siteConfig.EndpointName__c = 'MonsterBizAppsSiteRouterUAT';
            iConfigToUpdate.add(siteConfig);
        }

        //Validate Address update
        IntegrationConfig__c addrConfig = iConfigMap.get('ValidateAddress');
        if(addrConfig != null){
            addrConfig.EndpointName__c = 'AvalaraDevAddress';
            iConfigToUpdate.add(addrConfig);
        }

        //finally make the commit and update the records
        if(iConfigToUpdate.size() > 0){
            update iConfigToUpdate;
        }
    }

} // end class