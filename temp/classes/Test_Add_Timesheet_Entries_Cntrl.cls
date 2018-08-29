@istest
public class Test_Add_Timesheet_Entries_Cntrl {
    static testmethod void Add_Timesheet_Entries_Cntrl(){
        SOEUtility.SystemSettings_Insert();
        Department__c  service1 = SOEUtility.Dep_Insert('Service1');
        Role__c  Role = SOEUtility.Role_Insert('Imp Manager');
        SOE__c SOE = SOEUtility.SOE_Insert('newsoetemp1',service1.Id,true,true,false,false); 
        System.assertEquals(SOE.SOE_Title__c , 'newsoetemp1');
         user user1 = SOEUtility.user_insert('user--10@gmail.com');
        user1.Pay_Type__c='Hourly';
        user1.Rate_Card__c=200;
        Timesheet__c Timesheet1 = new Timesheet__c(PayPeriod_Start__c= System.today(),PayPeriod_End__c= System.today().adddays(4));
        Insert Timesheet1 ;
        Timesheet__c Timesheet2 = new Timesheet__c();
        Insert Timesheet2 ;
        Timesheet_Entry__c Timesheetentry = new Timesheet_Entry__c(SOE__c=SOE.id,Timesheet__c=Timesheet1.id,Start__c=System.now(),End__c=System.now().addminutes(5));  
        insert  Timesheetentry ; 
        Timesheet_Entry__c Timesheetentry1 = new Timesheet_Entry__c(SOE__c=SOE.id,Timesheet__c=Timesheet1.id,Start__c=System.now().addminutes(5),End__c=System.now());
        insert  Timesheetentry1 ; 
                   
        test.starttest(); 
            ApexPages.StandardController sc1 = new ApexPages.StandardController( new Timesheet__c());
            Apexpages.Currentpage().getParameters().put('id',Timesheet2.id);
        Add_Timesheet_Entries_Cntrl Deiltimesheet1= new Add_Timesheet_Entries_Cntrl(sc1);
           
            ApexPages.StandardController sc = new ApexPages.StandardController( new Timesheet__c());
            Apexpages.Currentpage().getParameters().put('id',Timesheet1.id);  
            Add_Timesheet_Entries_Cntrl Deiltimesheet= new Add_Timesheet_Entries_Cntrl(sc);
            Deiltimesheet.TsObj.PayPeriod_Start__c = null;
            Deiltimesheet.Create();            
            Deiltimesheet.TsObj.PayPeriod_Start__c=System.today().adddays(5);
            Deiltimesheet.TsObj.PayPeriod_End__c= System.today();
            Deiltimesheet.Create();
            Deiltimesheet.TsObj.PayPeriod_Start__c=System.now();            
            Deiltimesheet.TsObj.PayPeriod_End__c= System.now().adddays(5);
            Deiltimesheet.TsObj.PayPeriod_End__c= System.now().addHours(5);
            Deiltimesheet.Create();
            Deiltimesheet.entrycount =1;
            Deiltimesheet.deleteLI();
            Deiltimesheet.Create(); 
            Deiltimesheet.entrycount =2; 
            Deiltimesheet.deleteLI();
            Deiltimesheet.NewLI();  
            Deiltimesheet.entrycount =1; 
            Deiltimesheet.deleteLI();    
            Deiltimesheet.Create();
            Deiltimesheet.NewLI();
            Deiltimesheet.Create();
            Deiltimesheet.NewLI();
            Deiltimesheet.entrycount =1;
            Deiltimesheet.TSEntrywraplist[1].TSEntry.Start__c = null;
            Deiltimesheet.Create();
            Deiltimesheet.TSEntrywraplist[1].TSEntry.Start__c = System.now().addHours(124);
            Deiltimesheet.TSEntrywraplist[1].TSEntry.End__c = System.now().addHours(3);
            Deiltimesheet.Create();
            Deiltimesheet.TSEntrywraplist[1].TSEntry.Start__c = System.now().addHours(1);
            Deiltimesheet.TSEntrywraplist[1].TSEntry.End__c = System.now().addHours(3);
            Deiltimesheet.Create();
            Deiltimesheet.TSEntrywraplist[1].TSEntry.SOE__c = null;
            Deiltimesheet.Create();
            Deiltimesheet.TSEntrywraplist.clear();
            
            
            Timesheetentry = new Timesheet_Entry__c(SOE__c=SOE.id,Timesheet__c=Timesheet1.id,Start__c=System.now(),End__c=System.now().adddays(1));  
            insert  Timesheetentry ; 
            Deiltimesheet= new Add_Timesheet_Entries_Cntrl(sc);
            Deiltimesheet.Create();
            Deiltimesheet.TSEntrywraplist.clear();  
            Timesheetentry = new Timesheet_Entry__c(SOE__c=SOE.id,Timesheet__c=Timesheet1.id,Start__c=System.now(),End__c=System.now().addminutes(5));  
            insert  Timesheetentry ; 
            Deiltimesheet= new Add_Timesheet_Entries_Cntrl(sc);
            Deiltimesheet.Create(); 
            Timesheet1.Status__c = 'Waiting for Approval';
            update Timesheet1;
            Deiltimesheet= new Add_Timesheet_Entries_Cntrl(sc);
        test.stoptest();
    }
}