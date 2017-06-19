public class cloneAccount
{   
    public String idOfRec {get;set;}
    public Id accId {get;set;}
   
    public cloneAccount()
    {
     accId = ApexPages.CurrentPage().getparameters().get('AccountId');
     //cloneRec();
    }
   
    public pageReference cloneRec()
    {
        List<Contact> cons = new List<Contact>();
        system.debug('#accId###' +accId);
        List<Account> acc = [SELECT Name,ShippingCountry,Shippingcity,ShippingState,ShippingStreet FROM Account WHERE Id = : accId];
        List<Account> accCopy = acc.deepClone();
        accCopy[0].Name = acc[0].Name + '_dc';
        accCopy[0].Shippingcity = acc[0].Shippingcity;
        accCopy[0].ShippingStreet = acc[0].ShippingStreet;
         accCopy[0].ShippingState = acc[0].ShippingState;
         accCopy[0].ShippingCountry = acc[0].ShippingCountry;
        //accCopy.Name = acc.Name;
        system.debug('***entry***' +accCopy[0] + accCopy[0].ShippingCity);
        insert accCopy[0];
        
        PageReference redirect = new PageReference('/' + accCopy[0].id);

        return redirect;
        /*List<Contact> con = [SELECT Id, LastName, AccountId FROM Contact WHERE AccountId = : accId];
        for(Contact c : con)
        {
            Contact conCopy = c.clone(false,true);
            conCopy.AccountId = accCopy.Id;
            cons.add(conCopy);
        }
        insert cons; */
    }
}