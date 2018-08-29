@istest
Public class Test_TwilioUtility {
     @testSetup static void setup() {
           SOEUtility.SystemSettings_Insert();
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('Modify SOE12',service.id,true,true,false,false);
        System.assertEquals(SOE.SOE_Title__c , 'Modify SOE12');  
        SOEUtility.TwilioSettings_Insert('TwilioUtility','no');       
    }
    Static testmethod void twilio1(){ 
        Test.StartTest();  
            list<string> PhNumbers = new list<string>();
            PhNumbers.add('917889748596');
            System.assertEquals(PhNumbers[0] , '917889748596');
            TwilioUtility twilio = new TwilioUtility ();
            twilio.SendSMS(PhNumbers,'aaaaa'); 
            twilio.SendSMS2(PhNumbers,'aaaaa');            
        Test.StopTest();
    }
     Static testmethod void twilio2(){ 
        Test.StartTest();  
            list<string> PhNumbers = new list<string>();
            PhNumbers.add('917889748596');
            System.assertEquals(PhNumbers[0] , '917889748596');
            TwilioUtility twilio = new TwilioUtility ();
            twilio.SendCall('919553333148');            
        Test.StopTest();
    }
     Static testmethod void twilio3(){ 
        Test.StartTest();  
            list<string> PhNumbers = new list<string>();
            PhNumbers.add('917889748596');
            System.assertEquals(PhNumbers[0] , '917889748596');
            TwilioUtility twilio = new TwilioUtility ();
            twilio.SendSMS(PhNumbers,'aaaaa');
        Test.StopTest();
    }
    static testmethod void MIS_Call(){ 
        Test.StartTest();  
            MIS__c mis = SOEUtility.MIS_Insert('MIS insetrt1');
            System.assertEquals(mis.MIS_Title__c, 'MIS insetrt1');
            ApexPages.CurrentPage().getparameters().put('ActiveId', '919234567765');
            ApexPages.CurrentPage().getparameters().put('body1', 'sample message');
            ApexPages.CurrentPage().getparameters().put('id', mis.Id);
            MIS_AllTasks_Cntrl All = new MIS_AllTasks_Cntrl();
            All.CreateCall();           
            All.CreateSMS();
        Test.StopTest();
    }
    static testmethod void SOE_Call(){ 
        Test.StartTest();  
        User user1 = SOEUtility.USer_Insert('user--26--@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--26--@gmail.com'];
        system.runas(user1){
            Department__c service = SOEUtility.Dep_Insert('Service2');
            SOE__c SOE = SOEUtility.SOE_Insert('SOE--1123',service.Id,false,false,false,true);  
            System.assertEquals(SOE.SOE_Title__c , 'SOE--1123');
            ApexPages.CurrentPage().getparameters().put('ActiveId', '919234567765');
            ApexPages.CurrentPage().getparameters().put('body1', 'sample message');
            ApexPages.CurrentPage().getparameters().put('id', soe.Id);
            AllTasks_ClientSide_Cntrl  All = new AllTasks_ClientSide_Cntrl  ();
            All.CreateCall();
            All.CreateSMS();
        }
        Test.StopTest();
    }
 
}