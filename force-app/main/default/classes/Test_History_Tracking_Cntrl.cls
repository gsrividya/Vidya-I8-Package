@istest
Public class Test_History_Tracking_Cntrl{
    Public static i8Constants i8 = new I8Constants();
    Static testmethod void History_Tracking_Cntrl(){
           SOEUtility.SystemSettings_Insert();
            Department__c service = SOEUtility.Dep_Insert('Service2');
            Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
            SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service.Id,true,true,false,false);
            SOE__c SOE1 = SOEUtility.SOE_Insert('SOE1',service.Id,true,true,false,false);
            System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
            MIS__c mis1 = SOEUtility.MIS_Insert('dds');
            System.assertEquals(mis1.MIS_Title__c , 'dds');
            SOE1.MIS__c = mis1.id;
            update soe1;        
        Test.StartTest();
        
            ApexPages.CurrentPage().getparameters().put('Id', SOE1.Id);
            History_Tracking_Cntrl Add = new History_Tracking_Cntrl();
            Add.cancel();
                        
            ApexPages.CurrentPage().getparameters().put('Id', mis1.Id);
            Add = new History_Tracking_Cntrl();
            Add.cancel();
            
        Test.StopTest();
    }
}