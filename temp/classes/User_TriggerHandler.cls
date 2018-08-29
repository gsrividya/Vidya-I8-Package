/* 
Class Name        : User_TriggerHandler 
Trigger Name      : User_Trigger 
Test Class Name   : Test_USER_TriggerHandler
Purpose/Overview  : Trigger Handler for User Trigger.
                    When user is created, update default values for SOE My View and MIS My View Fields.
Author            : Purview Ltd.
Code Coverage     : Trigger Handler - 100%
                    Trigger - 100%
Change History    : 

*/


/***     Trigger Handler on User object         ***/
public class User_TriggerHandler {
    //Method declaration
    public static void setUserDefultValues(List<User> UserList){    
        for(User user : UserList){
            user.MIS_MyView__c = System.Label.MIS_MyView ;
            user.SOE_MyView__c = System.Label.SOE_MyView;
        }
    }   
}