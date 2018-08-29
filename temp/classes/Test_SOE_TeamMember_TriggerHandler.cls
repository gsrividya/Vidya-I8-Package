@istest
public class Test_SOE_TeamMember_TriggerHandler{
        
        Public static i8Constants i8 = new I8Constants();
        Static testmethod void SOE_Teammember_TriggerHandler(){
           SOEUtility.SystemSettings_Insert();
            Test.StartTest();
            Department__c  service1 = SOEUtility.Dep_Insert('Service1');
            Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
            SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service1.Id,true,true,false,false);
            System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
            list<task__c> Tas = [select id,name,Task_Title__c,SOE__c,Stage_Level__c,Stage__c,Team__c,Owner__c from task__c where SOE__c =:soe.id];
            ApexPages.CurrentPage().getparameters().put('id',soe.id);
             user user1 = SOEUtility.user_insert('user--20@gmail.com');
        Member__c member2 = [select id from Member__c where Email__c ='user--20@gmail.com'];
            SOE_Teammember_TriggerHandler TeamTrigger =new SOE_Teammember_TriggerHandler();            
            SOE_Team_Member__c SOETeam =SOEUtility.teammember_insert(member2.id,'Read',soe.id,role.Id);
            SOETeam.Access_Level__c='Edit';
            update SOETeam;
            delete SOETeam;
            Test.StopTest();   
        }
            
}