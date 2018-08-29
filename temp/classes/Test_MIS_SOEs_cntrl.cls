@istest
Public class Test_MIS_SOEs_cntrl {
    Public static i8Constants i8 = new I8Constants();
    Static testmethod void MIS_MIS_SOEs_cntrl1(){
           SOEUtility.SystemSettings_Insert();
           Member__c member = new Member__c();
       member.Name ='test member';
       member.Salesforce_User__c = UserInfo.getUserId();
       member.Email__c = 'sasa@gmail.com';
        member.Phone__c ='34343';
       insert member;
            Department__c service = SOEUtility.Dep_Insert('Service2');
            Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
            SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service.Id,true,true,false,false);
            System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
            SOE__c SOE1 = SOEUtility.SOE_Insert('SOE--1212',service.Id,true,true,false,false);
       
        MIS__c mis1 = SOEUtility.MIS_Insert('dds');
        Test.StartTest();
            ApexPages.CurrentPage().getparameters().put('Id', mis1.Id);
            MIS_SOEs_cntrl  mis= new MIS_SOEs_cntrl();
            mis.getLeftSOE();
            mis.Apply_method();
            list<id> soelist = new list<Id>{soe.id,soe1.id};
            mis.selectedleftSOE = soelist;
            mis.AddSOE();
            mis.getRightSOE();
            mis.Apply_method();
            mis.selectedrightSOE = soelist;
            mis.RemoveSOE();
            mis.AddAllSOEs();
            mis.RemoveAllSOEs();
            mis.refreshlist();
            mis.search_SOE = 'soe';
            mis.search_Action();
            mis.cancel_method();
            
            Test.StopTest();
    }
}