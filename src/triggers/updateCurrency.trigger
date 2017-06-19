trigger updateCurrency on Account (before insert, before update) {

/*Set<Id> userIds = new Set<Id>();
for(Account acc : trigger.new){
userIds.add(acc.OwnerId);
}

Map<Id, String> fieldMap = new Map<Id, String>();
for(User usr : [Select DefaultCurrencyIsoCode, Id From User Where Id IN: userIds]){
fieldMap.put(usr.Id, usr.DefaultCurrencyIsoCode);
}

for(Account accList : trigger.new){
accList.CurrencyIsoCode = fieldMap.get(accList.OwnerId);
}*/
}