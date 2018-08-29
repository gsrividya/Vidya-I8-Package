@istest
Public class Test_Broadcast_New_Cntrl {
    Public static i8Constants i8 = new I8Constants();
    Static testmethod void Broadcast_New_Cntrl(){
        SOEUtility.SystemSettings_Insert();
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service.Id,true,true,false,false);     
        System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
        list<Task__c> tas = [select id,Id_Text__c from Task__c where soe__c =: soe.Id and Stage_Level__c =: i8.CONTEXT_IMP order by Id_Before_Decimal__c,Id_After_Decimal__c];      
        Test.StartTest();
        Datetime dateTime1 = System.now();
        Broadcast_New_Cntrl broad=new Broadcast_New_Cntrl();
        broad.bc.All_Users__c= true;
        broad.bc.Message_Start_Date__c = datetime1;
        broad.bc.Message_End_Date__c = datetime1.addMinutes(5);
        broad.bc.Message__c='SOETeam';
        broad.Save();
        broad.bc.This_SOE_Users__c= true;
        broad.Save();
        broad.Cancel();
        Test.StopTest();
    }
}