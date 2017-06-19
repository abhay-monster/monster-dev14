/*
** @author : Cloud Sherpas Inc.
** @date : 09/08/2014
** @description : AccountAdvancedQuote Page Controller Class
*/
public class AccountAdvancedQuoteCtrl {
    
    private Account account {get;set;}
    
    public String selectedAction {get;set;}
    public String selectedProposalID {get;set;}
    
    public String message { get; set; }
    public String outputHTMLTable { get; set; }
    public Set<Id> setValidBIAProfiles = new Set<Id>();
    
    private AccountAdvancedQuoteHelper helper = new AccountAdvancedQuoteHelper();
    
    public list<SelectOption> actionList {
        get {
            if (actionList == null) {
                    actionList = new list<SelectOption>();
                    actionList.add(new SelectOption('','Please Select One'));
                    actionList.add(new SelectOption(AccountAdvancedQuoteHelper.MidContractQuote, AccountAdvancedQuoteHelper.MidContractQuote));
                    actionList.add(new SelectOption(AccountAdvancedQuoteHelper.Renewal,             AccountAdvancedQuoteHelper.Renewal));
                    actionList.add(new SelectOption(AccountAdvancedQuoteHelper.ResumeUpgrade,    AccountAdvancedQuoteHelper.ResumeUpgrade));
                    actionList.add(new SelectOption(AccountAdvancedQuoteHelper.ProductConversion, AccountAdvancedQuoteHelper.ProductConversion));
                    if(!setValidBIAProfiles.contains(Userinfo.getProfileId())){
                        actionList.add(new SelectOption(AccountAdvancedQuoteHelper.BIAUsage, AccountAdvancedQuoteHelper.BIAUsage)); // Added By Viraj Rana || 2016-12-21 || S-444777
                    }
                    actionList.add(new SelectOption(AccountAdvancedQuoteHelper.ProductExtension, AccountAdvancedQuoteHelper.ProductExtension));                          
            }
            return actionList;
        }
        private set;
    }

    public AccountAdvancedQuoteCtrl(ApexPages.StandardController controller) {
        system.debug('Inside AccountAdvancedQuoteCtrl constructor.');
        message = '';
        account = (Account)controller.getRecord();
        system.debug('Account:'+account);
        
        setValidBIAProfiles = (new map<Id,Profile>([Select id from Profile where name in ('Sales Rep (NA)','Sales Manager (NA)','Sales Operations (NA)','Sales Operations (TA)')])).Keyset();
    }
    
    public PageReference onSelectAction() {
        system.debug('Inside onSelectAction:' + selectedAction);
        message = '';
        outputHTMLTable = null;
        if(selectedAction == null || selectedAction == '') return null;
        outputHTMLTable = helper.getQuoteByAccountAction(selectedAction, account.ID);
        if(helper.quoteIDAssetLineItemMap == null || helper.quoteIDAssetLineItemMap.isEmpty()){
            message = 'No Asset eligible for ' + selectedAction + '.';
        }

        //Update Message
        if(helper.message != ''){
            message += ' Error Details:'+ helper.message;
        }
        return null;
    }
    
    public PageReference selectQuoteID() {
        system.debug('Inside selectQuoteID.');
        selectedProposalID = ApexPages.currentPage().getParameters().get('radioSelectValue');
        System.debug(LoggingLevel.INFO,'selectedProposalID:' + selectedProposalID);
        return null;
    }

    public PageReference onClickNext() {
        PageReference pref = null;
        message = '';
        System.debug(LoggingLevel.INFO,'Inside onClickNext selectedProposalID:' + selectedProposalID);
        ID newProposalID = helper.executeAccountActions(selectedAction, selectedProposalID, account.ID);
        //  Redirect to Apttus Instlled Product Page(param: new Proposal ID)
        //  start APTUS - I-159723 
        string sFLow = '';
        If(selectedAction == AccountAdvancedQuoteHelper.MidContractQuote )
        {
            sFLow = 'Mid Contract Flow';
        }else If(selectedAction == AccountAdvancedQuoteHelper.BIAUsage)
        {
            sFLow = 'BIAUsage';
        }
        else
        {
            sFLow = 'Default';
        }
        if(newProposalID != null){
            pref = new PageReference('/apex/Apttus_QPAsset__ProposalConfiguration?id=' + newProposalID + '&mode=addOn&flow='+sFLow+'&useAdvancedApproval=true');
        }else{
            message = helper.message;
        }
        //  End APTUS - I-159723 – 
        return pref;
    }
    
    public PageReference onClickCancel() {
        If(account != null){
            PageReference accountPage = new ApexPages.StandardController(account).view();
            accountPage.setRedirect(true);
            return accountPage; 
        }else{
            return new PageReference('/001');
        }
    }
}