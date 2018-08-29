@istest(SeeAllData=true)
Public class Test_SOE_DashBoards_Cntrl{  
 Static testmethod void SOE_DashBoards(){
     i8Constants i8 = new I8Constants();
   Test.StartTest(); 
      Department__c  service1 = SOEUtility.Dep_Insert('Service1');
      Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
       User user1 = SOEUtility.USer_Insert('user--26--@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--26--@gmail.com'];
      system.runas(user1){
      SOE__c SOE1 = SOEUtility.SOE_Insert('newsoetemp',service1.Id,true,true,false,false); 
      System.assertEquals(SOE1.SOE_Title__c , 'newsoetemp');
      apexpages.currentpage().getparameters().put('id',soe1.id);
      SOE_DashBoards_Cntrl SoeDashboard=new SOE_DashBoards_Cntrl(); 
      soe1.Schedule_Start__c = System.Now().AddMinutes(5);
      soe1.Schedule_End__c = System.Now().AddHours(5);
      soe1.Warning_Zone__c = System.Now().AddHours(5);
      soe1.BAU_Impact__c = System.Now().AddHours(5);
      soe1.Status__c = i8.STATUS_FREEZE;
      update soe1;
      list<Task__c> tas = [select id,Id_Text__c from Task__c where soe__c =: soe1.Id and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_Decimal__c,Id_After_Decimal__c];
      tas[3].Start_Time__c = System.Now().AddDays(5);
      tas[3].End_Time__c = tas[3].Start_Time__c .AddMinutes(5);
      tas[3].Status__c = i8.STATUS_FREEZE;
      update tas[3];
      Task_TriggerHandler.UpdateAllTasks(new list<id>{soe1.Id},i8.CONTEXT_IMP);
      SoeDashboard=new SOE_DashBoards_Cntrl();
      soe1.status__c = i8.STATUS_IMP_COMP;
      update soe1;
      SoeDashboard=new SOE_DashBoards_Cntrl();
      soedashboard.openCancel();
      soedashboard.OPenReport();
      }
      Test.StopTest();  
  }
  Static testmethod void Report_Cntrl1(){
      Test.StartTest();
      User user1 = SOEUtility.USer_Insert('user--26--@gmail.com');
      Member__c member1 = [select id from Member__c where Email__c ='user--26--@gmail.com'];
      system.runas(user1){
          Department__c  service1 = SOEUtility.Dep_Insert('Service1');
          SOE__c SOE1 = SOEUtility.SOE_Insert('newsoetemp1212',service1.Id,true,true,false,false); 
          System.assertEquals(SOE1.SOE_Title__c , 'newsoetemp1212');
          ApexPAges.CurrentPAge().getPArameters().put('pn0','s-120');
          ApexPAges.CurrentPAge().getPArameters().put('pv0','s-120');
          ApexPAges.CurrentPAge().getPArameters().put('pv1','s-120');
          Report_Cntrl rc = new Report_Cntrl();
          ApexPAges.CurrentPAge().getPArameters().put('pc0','s-120');
          rc = new Report_Cntrl();
          ApexPAges.CurrentPAge().getPArameters().put('pc0',null);
          ApexPAges.CurrentPAge().getPArameters().put('pn0',null);
          ApexPAges.CurrentPAge().getPArameters().put('pv0','s-120');
          rc = new Report_Cntrl();
      }
      Test.StopTest();
  }
}