@istest
Public class Test_Rota_Cntrl{
    Public static i8Constants i8 = new I8Constants();
    Static testmethod void Rota_Cntrl(){
           SOEUtility.SystemSettings_Insert();
            Department__c service = SOEUtility.Dep_Insert('Service2');
            Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
            SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service.Id,true,true,false,false);
            System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
            MIS__c mis1 = SOEUtility.MIS_Insert('dds');
            System.assertEquals(mis1.MIS_Title__c , 'dds');
            soe.MIS__c = mis1.id;
            update soe; 
        
        Test.StartTest();
            ApexPages.CurrentPage().getparameters().put('Id',SOE.Id);
            Rota_Cntrl R = New Rota_Cntrl();
            R.CancelTask();
            
            ApexPages.CurrentPage().getparameters().put('Id',mis1.Id);
            R = New Rota_Cntrl();
            R.CancelTask();            
        Test.StopTest();
    }
}