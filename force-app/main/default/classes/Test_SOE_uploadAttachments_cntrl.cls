@istest
Public class Test_SOE_uploadAttachments_cntrl  {
    Static testmethod void SOE_uploadAttachments_cntrl (){
           SOEUtility.SystemSettings_Insert();
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service.Id,true,true,false,false);     
        System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
        Test.StartTest();
            User user1 = SOEUtility.USer_Insert('user--35--@gmail.com');
            Member__c member1 = [select id from Member__c where Email__c ='user--35--@gmail.com'];
            SOE_Team_Member__c stm1 = SOEUtility.teammember_insert(member1.id,'Read',soe.id,role.id);
            ApexPages.CurrentPage().getparameters().put('id',SOE.Id); 
             SOE_uploadAttachments_cntrl  uploading=new SOE_uploadAttachments_cntrl ();
             uploading.upload();
             uploading.upload();
             uploading.fileName='abc.mp3';
             string mystring='stringtoblob';
             uploading.upload();
             uploading.fileBody=Blob.valueof(mystring);
             uploading.upload(); 
             uploading.CancelTAsk();
             uploading.fileName='abc.docx.pdf.xlsx';
             mystring='stringtoblob';
             uploading.fileBody=Blob.valueof(mystring);
             Uploading.SOEId = '01p58000001niJL';
             uploading.upload();
         Test.StopTest();
    }
}