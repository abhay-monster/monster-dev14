/**
* @author Original: robby angeles
* @date   Original: 02 DEC 2014
* @description schedulable class that calls the AccountLevelUpdate batch class
*               code to run batch class from console - Id bcAccounLevelUpdate = Database.executeBatch(new AccountLevelUpdate(), 200);
* @History - 02 DEC 2014 - robby angeles - created
*/ 
global class AccountLevelUpdateSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new AccountLevelUpdate(), 200);
    }
}