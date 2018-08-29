@istest
Public class Test_SOE_Schedule_Cntrl{
        @testSetup static void setup() {
           SOEUtility.SystemSettings_Insert();
           Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
           role = [select id,Reference_Role__c from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
           System.assertEquals(role.Reference_Role__c , 'Imp Manager');
        }
     Static testmethod void SOE_Schedule_Cntrl(){     
        Department__c  service1 = SOEUtility.Dep_Insert('Service2');
       role__c role = [select id from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
        SOE__c SOE = SOEUtility.SOE_Insert('SOE 16/10',service1.Id,true,true,false,false);
        System.assertEquals(SOE.SOE_Title__c , 'SOE 16/10');
        SOE__c SOE1 = SOEUtility.SOE_Insert('SOE1 16/10',service1.Id,true,true,false,false);
        test.starttest();
        SOE.Status__c = 'Review';
        Update SOE;
        SOE1.Status__c = 'Review';
        Update SOE1;
        SOE__c SOE3 = SOEUtility.SOE_Insert('SOE3 16/10',service1.Id,true,true,false,false);
        Integer duration =56;
        ApexPages.currentPage().getParameters().put('id', SOE3.id);
        SOE_Schedule_Cntrl SOETest_test = new SOE_Schedule_Cntrl();
        ApexPages.currentPage().getParameters().put('id', SOE.id);
        ApexPages.CurrentPage().getParameters().put('duration',String.valueOf(duration)); 
        SOE_Schedule_Cntrl SOETest = new SOE_Schedule_Cntrl();
        SOETest.Apply();
        SOE.Schedule_Start__c = system.now()+2;
        SOE.Schedule_End__c = system.now()+1;
        SOE.Warning_Zone__c = system.now();
        SOE.BAU_Impact__c = system.now()-1;
        update SOE;
        ApexPages.currentPage().getParameters().put('id', SOE.id);
        SOE_Schedule_Cntrl SOETest1 = new SOE_Schedule_Cntrl();
        SOETest1.change_end();
        SOETest1.Cancel();
        SOETest1.Apply();
        SOETest1.errorbool = false;
        SOETest1.Apply();
        ApexPages.currentPage().getParameters().put('id', SOE1.id);
        SOE_Schedule_Cntrl SOETest2 = new SOE_Schedule_Cntrl();
        SOETest2.duration = 59000;
        SOETest2.SOE.Schedule_Start__c = system.now().addSeconds(-5);
        SOETest2.Apply();
        SOETest2.SOE.Schedule_Start__c = system.now().addSeconds(5);
        SOETest2.SOE.Schedule_End__c = system.now().addSeconds(7);
        SOETest2.SOE.Warning_Zone__c = system.now().addSeconds(8);
        SOETest2.SOE.BAU_Impact__c = system.now().addSeconds(27);
        SOETest2.Apply();
        SOETest2.Cancel();
        test.stoptest();
        ApexPages.currentPage().getParameters().put('id', SOE1.id);
        ApexPages.currentPage().getParameters().put('page', 'detail');
        SOE_Schedule_Cntrl SOETest3 = new SOE_Schedule_Cntrl();
        SOETest3.duration = 590000;
        SOETest3.SOE.Schedule_Start__c = system.now().addSeconds(5);
        SOETest3.SOE.Schedule_End__c = system.now().addSeconds(7);
        SOETest3.SOE.Warning_Zone__c = system.now().addSeconds(8);
        SOETest3.SOE.BAU_Impact__c = system.now().addSeconds(27);
        SOETest3.Apply();
        SOETest3.Cancel();        
     }
      Static testmethod void SOE_Schedule_Cntr2(){     
        Department__c  service1 = SOEUtility.Dep_Insert('Service2');
        role__c role = [select id from Role__c where Reference_Role__c = 'Imp Manager' limit 1];
        SOE__c SOE = SOEUtility.SOE_Insert('SOE 16/10',service1.Id,true,true,false,false);
        System.assertEquals(SOE.SOE_Title__c , 'SOE 16/10');        
        test.starttest();
        User user1 = SOEUtility.USer_Insert('user--25--@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--25--@gmail.com'];
        SOE_Team_Member__c stm1 = SOEUtility.teammember_insert(member1.id,'Read',soe.id,role.id);
        soe.Status__c = 'Review';
        soe.QA_Review__c = 'In Progress';
        update soe;
        ApexPages.currentPage().getParameters().put('id', SOE.id);
        SOE_Schedule_Cntrl SOETest2 = new SOE_Schedule_Cntrl();
        soe.QA_Review__c = 'Complete';
        update soe;
        system.runas(user1){
            SOETest2 = new SOE_Schedule_Cntrl();
        }
        soetest2.soe = null;
        soetest2.Apply();
        test.stoptest();
     }
}