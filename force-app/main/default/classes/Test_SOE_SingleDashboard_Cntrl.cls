@istest
Public class Test_SOE_SingleDashboard_Cntrl {
    Static testmethod void broadcast_method1(){
           SOEUtility.SystemSettings_Insert();
        Test.StartTest();
        BroadCast__c  bc = SOEUtility.Broadcast_Insert('sad');
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('SOE--1c',service.Id,true,true,false,false);  
        System.assertEquals(SOE.SOE_Title__c , 'SOE--1c');
        ApexPages.CurrentPage().getparameters().put('Id', soe.Id);
        SOE_SingleDashboard_Cntrl All = new SOE_SingleDashboard_Cntrl();
        SOE_SingleDashboard_Cntrl.getTasks(soe.id,0,8);
        All.openCancel();
        Test.StopTest();
   }
}