@istest
Public class Test_Import_ROTA_Cntrl{
    Public static i8Constants i8 = new I8Constants();
    Static testmethod void Import_ROTA_cntrl(){
           SOEUtility.SystemSettings_Insert();
        Department__c service = SOEUtility.Dep_Insert('Service2');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('SOE--1',service.Id,true,true,false,false);
        System.assertEquals(SOE.SOE_Title__c , 'SOE--1');
        Test.StartTest();
        Import_ROTA_cntrl imp_tas_cntrl = new Import_ROTA_cntrl();
        imp_tas_cntrl.nameFile ='.csv';
        imp_tas_cntrl.ReadFile();
        Soe__c Soe1=[select id,name from Soe__c where id=:SOE.id];
        String Task2 = '\n,\n'+Soe1.name+',Rota,Build,sasas@gmail.com, , , , , , , , , , , , , , , , ';
        Blob csvfile2 = Blob.valueof(Task2);
        imp_tas_cntrl.contentFile = csvfile2;
        imp_tas_cntrl.ReadFile();
        String Task1 = '\n,\n'+Soe1.name+',Rota,Build,sasas@gmail.com, , , , , , , , , , , , , , , , \n s-1234,Rota,Build,sasas@gmail.com, , , , , , , , , , , , , , , , \n , rota, build,sdsd@gmail.com, , , , , , , , , , , ,'+system.now()+','+system.now().adddays(2)+', , , ';
        Blob csvfile1 = Blob.valueof(Task1);
        imp_tas_cntrl.contentFile = csvfile1;
        imp_tas_cntrl.ReadFile();
        imp_tas_cntrl.CancelROTA();
        
        Import_ROTA_cntrl imp_tas_cntrl1 = new Import_ROTA_cntrl();
        imp_tas_cntrl1.nameFile ='.csv';
        imp_tas_cntrl1.ReadFile();
        String Tas = '\n,\n'+'SFDC'+',Rota,Build,sasas@gmail.com, , , , , , , , , , , , , , , , \n s-1234,Rota,Build,sasas@gmail.com, , , , , , , , , , , , , , , , \n , rota, build,sdsd@gmail.com, , , , , , , , , , , ,'+system.now()+','+system.now().adddays(2)+', , , ';
        Blob csv = Blob.valueof(Tas);
        imp_tas_cntrl1.contentFile = csv;
        imp_tas_cntrl1.ReadFile();
        String Tas1 = '\n,\n'+'SFDC'+',,,sasas@gmail.com, , , , , , , , , , , , , , , , \n s-1234,Rota,Build,sasas@gmail.com, , , , , , , , , , , , , , , , \n , rota, build,sdsd@gmail.com, , , , , , , , , , , ,'+system.now()+','+system.now().adddays(2)+', , , ';
        Blob csv1 = Blob.valueof(Tas1);
        imp_tas_cntrl1.contentFile = csv1;
        imp_tas_cntrl1.ReadFile();
        Import_ROTA_cntrl imp_tas_cntrl2 = new Import_ROTA_cntrl();
        imp_tas_cntrl2.nameFile ='.csv';
        imp_tas_cntrl2.ReadFile();
        String Tas2 = '\n,\n'+''+',,,sasas@gmail.com, , , , , , , , , , , , , , , , \n s-1234,Rota,Build,sasas@gmail.com, , , , , , , , , , , , , , , , \n , rota, build,sdsd@gmail.com, , , , , , , , , , , ,'+system.now()+','+system.now().adddays(2)+', , , ';
        Blob csv2 = Blob.valueof(Tas2);
        imp_tas_cntrl2.contentFile = csv2;
        imp_tas_cntrl2.ReadFile();
        Test.StopTest();
    }
}