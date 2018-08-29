@istest
public class Test_SOE_Trigger_Handler{  
    @testSetup static void setup() {
           SOEUtility.SystemSettings_Insert();
            Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
            role = [select id,Reference_Role__c  from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
            System.assertEquals(role.Reference_Role__c , 'Imp Manager');
           }
    public static SOE__c SOE_Insert(string title,Id service,Boolean pre,Boolean Post,Boolean Backout,Boolean QA,Boolean WT){
        SOE__c SOE= new SOE__c();
        SOE.SOE_Title__c = title;
        SOE.Department__c = service;
        SOE.Pre_Implementation_Stage__c = pre;
        SOE.Post_Implementation_Stage__c = post;
        SOE.BackOut_Stage__c= Backout;
        SOE.QA_Review_Required__c = QA;        
        SOE.WalkThrough_Required__c = WT;
        SOE.Baseline_Start__c = system.now();
        if(soe.BackOut_Stage__c == true)
            soe.Backout__c = 'Manual';
        soe.Summary__c = 'sdfsdfsd';
        insert SOE;
        return SOE;
    }
    
    static testmethod void Test_SOE(){    
        Test.StartTest();        
        Department__c  service1 = SOEUtility.Dep_Insert('Service1');
        SOE__c SOE1 = SOEUtility.SOE_Insert('newsoeinc',service1.Id,true,false,false,false);
        System.assertEquals(SOE1.SOE_Title__c , 'newsoeinc');
        SOE__c SOE2 = SOEUtility.SOE_Insert('newsoeinc1',service1.Id,false,true,false,false);
        SOE__c SOE3 = SOE_Insert('newsoeinc2',service1.Id,false,true,true,false,false); 
         user user1 = SOEUtility.user_insert('user--21@gmail.com');
        SOE3.QA_Review_Required__c = true;
        SOE3.QA_Manager__c = user1.id;
        update SOE3;
         Test.StopTest(); 
        user user2 = SOEUtility.user_insert1('user--22@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--22@gmail.com'];
        id Id1;
        Role__c role = SOEUtility.Role_insert('QA Manager');
        SOE_Team_Member__c  stm1 = SOEUtility.teammember_insert(member1.id,'Edit',SOE3.Id,id1);
        SOE3.QA_Manager__c = user2.id;
        update SOE3;
        SOE3.QA_Manager__c = null;
        update SOE3;          
    }
      static testmethod void Test_SOE1(){    
        Test.StartTest();  
        Role__c role = [select id,Reference_Role__c  from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
        User user1 = SOEUtility.USer_Insert('user--34--@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--34--@gmail.com'];            
        Department__c  service1 = SOEUtility.Dep_Insert('Service1');
        SOE__c SOE1 = SOEUtility.SOE_Insert('newsoeinc111',service1.Id,false,false,false,false);
        System.assertEquals(SOE1.SOE_Title__c , 'newsoeinc111');
        SOE_Team_Member__c stm1 = SOEUtility.teammember_insert(member1.id,'Edit',soe1.id,role.id);
        MIS__c mis1 = SOEUtility.MIS_Insert('dds');
        soe1.MIS__c = mis1.id;
        soe1.Status__c = 'Imp In Progress';
        update soe1;
        soe1.Schedule_Start__c = System.Now();
        soe1.Schedule_End__c = System.Now().addHours(1);
        soe1.Warning_Zone__c = System.Now().Addhours(2);
        soe1.BAU_Impact__c = System.Now().Addhours(3);
        update soe1;
        Member__c member = SOEUtility.Member_Insert('xxxx',UserInfo.getUserId(),'232323','sasa@gmail.com');
        MIS__c mis2 = SOEUtility.MIS_Insert('dds12');
        soe1.MIS__c = mis2.id;
        update soe1;
        Test.StopTest();
    }
}