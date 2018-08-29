@istest
Public class Test_Communication_TriggerHandler {
    @testSetup static void setup() {
        SOEUtility.SystemSettings_Insert();
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('Task Communication 1',service.id,true,true,false,false);
        System.assertEquals(SOE.SOE_Title__c , 'Task Communication 1');      
    }
    Static testmethod void Comm_Milestone(){ 
        Test.StartTest();     
        SOE__c soe = [select id,SOE_Title__c from SOE__c where SOE_Title__c ='Task Communication 1'];     
        System.assertEquals(SOE.SOE_Title__c , 'Task Communication 1'); 
        list<task__c> Tas = [select id,name,Task_Title__c,SOE__c,Stage_Level__c,Stage__c,Team__c,Owner__c from task__c where SOE__c =: SOE.id order by ID_Before_Decimal__c,Id_After_Decimal__c];      
        Communication__c  com = SOEUtility.COMM_Insert(tas[1].id,soe.id,false,null,null,null,null);
        tas[1].Milestone__c = true;
        update tas[1];
         User user1 = SOEUtility.USer_Insert('user--39--@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--39--@gmail.com'];
        Role__c role = [select id from ROle__c where Reference_Role__c = 'Imp Manager' limit 1];
        SOE_Team_Member__c stm1 = SOEUtility.teammember_insert(member1.id,'Edit',soe.id,role.id);
        Member__c member2 = SOEUtility.Member_Insert('member1',null,'918978478545','membermail@gmail.com');
        com.MileStone_for_default_Imp_Mngrs__c  = true;
        update com;
        com.Milestone_Members__c = member2.id;
        update com;
        com.Additinal_Emails_Milestone__c ='gsfdg@gmail.com';
        update com;
        com.Additional_Phone_Milestone__c  ='9178974851412';
        update com;
        Test.StopTest();
     }
     Static testmethod void Comm_TaskReady(){ 
        Test.StartTest();     
        SOE__c soe = [select id,SOE_Title__c from SOE__c where SOE_Title__c ='Task Communication 1'];     
        System.assertEquals(SOE.SOE_Title__c , 'Task Communication 1'); 
        list<task__c> Tas = [select id,name,Task_Title__c,SOE__c,Stage_Level__c,Stage__c,Team__c,Owner__c from task__c where SOE__c =: SOE.id order by ID_Before_Decimal__c,Id_After_Decimal__c];      
        Communication__c  com = SOEUtility.COMM_Insert(tas[1].id,soe.id,false,null,null,null,null);        
        User user1 = SOEUtility.USer_Insert('user--39--@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--39--@gmail.com'];
        Team__c team = SOEUtility.Team_Insert('team2');
        Team_Member__c tmember = SOEUtility.Teammember_insert(member1.id,team.id);
        tas[1].Team__c = team.id;
        tas[1].Owner__c = tmember.id;
        tas[1].When_Task_Ready__c = true;
        update tas[1];
        Member__c member2 = SOEUtility.Member_Insert('member1',null,'918978478545','membermail@gmail.com');
        com.Default_Owner_Task_ready__c  = true;
        update com;
        com.Task_Ready_Members__c = member2.id;
        update com;
        com.Additinal_Emails_Task_Ready__c ='gsfdg@gmail.com';
        update com;
        com.Additional_Phone_Task_Ready__c ='9178974851412';
        update com;
        tas[1].Status__c = 'Ready';
        update tas[1];
        Test.StopTest();
     }
     Static testmethod void Comm_TaskCompleted(){ 
        Test.StartTest();     
        SOE__c soe = [select id,SOE_Title__c from SOE__c where SOE_Title__c ='Task Communication 1'];     
        System.assertEquals(SOE.SOE_Title__c , 'Task Communication 1'); 
        list<task__c> Tas = [select id,name,Task_Title__c,SOE__c,Stage_Level__c,Stage__c,Team__c,Owner__c from task__c where SOE__c =: SOE.id order by ID_Before_Decimal__c,Id_After_Decimal__c];      
        Communication__c  com = SOEUtility.COMM_Insert(tas[1].id,soe.id,false,null,null,null,null);
        tas[1].Task_Completed__c = true;
        update tas[1];
         User user1 = SOEUtility.USer_Insert('user--39--@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--39--@gmail.com'];
        Role__c role = [select id from ROle__c where Reference_Role__c = 'Imp Manager' limit 1];
        SOE_Team_Member__c stm1 = SOEUtility.teammember_insert(member1.id,'Edit',soe.id,role.id);
        Member__c member2 = SOEUtility.Member_Insert('member1',null,'918978478545','membermail@gmail.com');
        com.Default_Owner_Completed__c  = true;
        update com;
        com.Completed_Members__c = member2.id;
        update com;
        com.Additional_Emails_Completed__c ='gsfdg@gmail.com';
        update com;
        com.Additional_Phone_Completed__c ='9178974851412';
        update com;
        tas[1].Status__c = 'Completed';
        update tas[1];
        Test.StopTest();
     }
}