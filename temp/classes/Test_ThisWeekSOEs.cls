@istest
Public class Test_ThisWeekSOEs{
    Public static i8Constants i8 = new I8Constants();
    Static testmethod void Add_Task_cntrl(){
           SOEUtility.SystemSettings_Insert();
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('SOE--111',service.Id,true,true,false,false);
        System.assertEquals(SOE.SOE_Title__c , 'SOE--111');
        Test.StartTest();
            ThisWeekSOEs Add = new ThisWeekSOEs();
        Test.StopTest();
    }
}