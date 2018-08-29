@istest(SeeAllData=true)
Public class Test_MIS_DashBoards_Cntrl {  
    Static testmethod void MIS_DashBoards(){
         i8Constants i8 = new I8Constants();   
          Department__c  service1 = SOEUtility.Dep_Insert('Service1');
          Role__c  Role =  SOEUtility.Role_Insert('Imp Manager');
          User user1 = SOEUtility.USer_Insert('user--26--@gmail.com');
          Member__c member1 = [select id from Member__c where Email__c ='user--26--@gmail.com'];
          Test.StartTest(); 
          system.runas(user1){
              SOE__c SOE1 = SOEUtility.SOE_Insert('newsoetemp',service1.Id,true,true,false,false); 
              System.assertEquals(SOE1.SOE_Title__c , 'newsoetemp');
              MIS__c mis1 = SOEUtility.MIS_Insert('dds');
              System.assertEquals(mis1.MIS_Title__c , 'dds');
              soe1.MIS__c = mis1.id;
              update soe1;
              SOE__c SOE2 = SOEUtility.SOE_Insert('newsoetemp123123',service1.Id,true,true,false,false);
              soe2.MIS__c = mis1.id;
              update soe2;
              apexpages.currentpage().getparameters().put('id',mis1.id);
              MIS_DashBoards_Cntrl MISDashboard=new MIS_DashBoards_Cntrl(); 
              MISDashboard.OPenCancel();
              MISDashboard.OpenReport();
         }  
         Test.stoptest();  
    }   
}