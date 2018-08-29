@istest
Public class Test_Email_Page{
    Public static i8Constants i8 = new I8Constants();
        Static testmethod void Email_Page_Cntrl(){
        SOEUtility.SystemSettings_Insert();
        Test.StartTest();
             user user1 = SOEUtility.user_insert('user--12@gmail.com');
        Member__c member1 = [select id from Member__c where Email__c ='user--12@gmail.com'];
            Department__c  service = SOEUtility.Dep_Insert('Service2');
            SOE__c SOE = SOEUtility.SOE_Insert('SOE-/-1',service.Id,true,true,false,false);
            System.assertEquals(SOE.SOE_Title__c , 'SOE-/-1');

            ApexPages.CurrentPage().getparameters().put('Id', SOE.Id);
            Email_Page_Cntrl Email = New Email_Page_Cntrl();
            Email.ExternalMails = 'venkatesh.2630@gmail.com,venkatesh.30@gmail.com';
            Email.emailbody = 'xyx';
            Email.SOE.Conference_Call_No__c = '8888998988';
            Email.SOE.Summary__c = 'descript';
            Email.SOE.Change_Record__c = 'record';
            Email.getLeftUsers();
            Email.getRightUsers();
            Email.leftselected.add(User1.Id);
            Email.AddUsers();
            Email.RightSelected.add(User1.Id);
            Email.DeleteUsers();
            Email.AddAllUsers();
            Email.SendMail();
            Email.ClearRightUsers();
            Email.selectformat();
            Email.getselectformatoption();
            Email.close();
            Email.reset();
            Email.Cancel();
    
            ApexPages.CurrentPage().getparameters().put('Id', SOE.Id);
            Email = New Email_Page_Cntrl();
            Email.selectaction = 'Excel';
            Email.ExternalMails = 'venkatesh.2630@gmail.com,venkatesh.260@gmail.com,venkatesh.263@gmail.com';
            Email.emailbody = '';
            Email.SendMail();
            Email.AddAllUsers();
            Email.SendMail();
            Email.selectformat();
            Email.getselectformatoption();
                
            ApexPages.CurrentPage().getparameters().put('Id', SOE.Id);
            Email = New Email_Page_Cntrl();
            Email.ExternalMails = '';
            Email.emailbody = '';
            Email.getLeftUsers();
            Email.getRightUsers();
            Email.DeleteAllUsers();
            Email.SendMail();           

            ApexPages.CurrentPage().getparameters().put('page', 'detail');
            ApexPages.CurrentPage().getparameters().put('Id', SOE.Id);
            Email = New Email_Page_Cntrl();
            Email.Cancel();
       Test.StopTest();
    }
}