@istest
Public class Test_Broadcast_TriggerHandler {
    @testSetup static void setup() {
           SOEUtility.SystemSettings_Insert();
           Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
           role = [select id,Reference_Role__c  from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
           System.assertEquals(role.Reference_Role__c , 'Imp Manager');
    }
   Static testmethod void broadcast_method1(){
        user user2 = SOEUtility.user_insert('user1ght--2@gmail.com'); 
        BroadCast__c  bc = SOEUtility.Broadcast_Insert('sad');
        user2 = [select id,name,Email from user where id=:user2.id];
        System.assertEquals(user2.Email, 'user1ght--2@gmail.com');
    }
    Static testmethod void broadcast_method2(){
        BroadCast__c  bc = SOEUtility.Broadcast_Insert('sad');
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c  Role =  [select id,Reference_Role__c  from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
        SOE__c SOE = SOEUtility.SOE_Insert('SOE--1a',service.Id,true,true,false,false);  
        System.assertEquals(SOE.SOE_Title__c , 'SOE--1a');  
        list<task__c> Tas = [select id,name,Task_Title__c,SOE__c,Stage_Level__c,Stage__c,Team__c,Owner__c from task__c where Stage__c =: 'Pre' and SOE__c =: soe.id order by Id_After_Decimal__c]; 
        user user1 = SOEUtility.user_insert('userqwer--2@gmail.com'); 
        Member__c member1 = [select id from Member__c where Email__c ='userqwer--2@gmail.com'];   
        Team__c Team1=SOEUtility.Team_insert('sap');
        Team_Member__c Teammember1=SOEUtility.Teammember_insert(member1.id,Team1.id);
        tas[1].Team__c = team1.id;
        tas[1].Owner__c = teammember1.id;
        update tas[1];
        bc.This_SOE_Users__c = true ;
        bc.All_Users__c = false;
        bc.SOE__c = soe.id;
        update bc;
     }
}