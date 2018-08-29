@istest
Public class Test_Export_SOE_CSV_Cntrl{
    Public static i8Constants i8 = new I8Constants();
    Static testmethod void Export_SOE_CSV_Cntrl1(){
           SOEUtility.SystemSettings_Insert();
            Department__c service = SOEUtility.Dep_Insert('Service2');
            Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
            SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service.Id,true,true,false,false);
            System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
            list<task__c> Tas = [select id,name,Task_Title__c,SOE__c,Stage_Level__c,Stage__c,Team__c,Owner__c from task__c where SOE__c =: SOE.id];
        Test.StartTest();
            ApexPages.CurrentPage().getparameters().put('Id', TAS[0].Id);
            Export_SOE_CSV_Cntrl Add = new Export_SOE_CSV_Cntrl();
         Test.StopTest();
     }
}