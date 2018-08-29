@isTest   
Public class Test_Soe_AllAttachments_Cntrl {
    Static testmethod void Soe_AllAttachments_Cntrl (){
           SOEUtility.SystemSettings_Insert();
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service.Id,true,true,false,false);     
        System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
        Test.StartTest();
            ApexPages.CurrentPage().getparameters().put('id',SOE.Id); 
            Soe_AllAttachments_Cntrl controller = new Soe_AllAttachments_Cntrl(new ApexPages.StandardController(SOE )); 
            controller.openCancel();
        Test.StopTest();
    }    
}