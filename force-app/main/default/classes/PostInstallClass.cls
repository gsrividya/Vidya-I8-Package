global class PostInstallClass implements InstallHandler {
   /*    
Class Name        : PostInstallClass 
Test Class Name   : Test_PostInstallClass
Purpose/Overview  : This class will insert seed data after I8 package installation on customer org. 
                    No user interface for this call.
Author            : Purview Ltd.
Code Coverage     : 100%
Change History    : 

*/    
    global void onInstall(InstallContext context) {
        //if package is installed for the first time
        if(context.previousVersion() == null) {
            //insert the member record for who has installing the package
                User u = [Select Id, Email,USerName from User where Id =:context.installerID()];  
                Member__c member = new Member__c(Name= u.UserName, Salesforce_User__C = u.id);
                if(Schema.sObjectType.Member__c.isCreateable())
                    insert member;
                // insert the default Role records
                list<Role__c> RoleList = new list<Role__c>();
                RoleList.add(new Role__c(Name='Imp Manager', Reference_Role__c = 'Imp Manager',Default_SOE_Manager__c = true));
                RoleList.add( new Role__c(Name='QA Manager', Reference_Role__c = 'QA Manager'));
                RoleList.add(new Role__c(Name='Incident Manager', Reference_Role__c = 'Incident Manager'));
                RoleList.add( new Role__c(Name='Task Owner', Reference_Role__c = 'Task Owner'));
                if(Schema.sObjectType.Role__c.isCreateable())
                    insert  RoleList ;
                // insert the Settings to System Setting Object
                list<System_Setting__c > SettingList = new list<System_Setting__c>();
                SettingList.add(new System_Setting__c(Name='Twilio Class Name',Key__c = 'Twilio_Class_Name',Value__c = 'TwilioUtility',Categories__c ='Twilio Settings'));
                SettingList.add(new System_Setting__c(Name='Twilio Installed',Key__c = 'Twilio_Installed',Value__c = 'no',Categories__c ='Twilio Settings'));
                SettingList.add(new System_Setting__c(Name='Twilio Account SId',Key__c = 'Twilio_Account_SId',Categories__c ='Twilio Settings'));
                SettingList.add( new System_Setting__c(Name='Twilio Auth Token',Key__c = 'Twilio_Auth_Token',Categories__c ='Twilio Settings'));
                SettingList.add(new System_Setting__c(Name='Twilio From Number',Key__c = 'Twilio_From_Number',Categories__c ='Twilio Settings'));
                SettingList.add( new System_Setting__c(Name='LOG ENABLE',Key__c = 'LOG_ENABLE',Value__c='false',Categories__c ='General Settings'));
                SettingList.add(new System_Setting__c(Name='LOG LEVEL',Key__c = 'LOG_LEVEL',Value__c ='ERROR; INFO; DEBUG;',Categories__c ='General Settings'));
                SettingList.add( new System_Setting__c(Name='Acceped Document Types',Key__c = 'Accepted_Document_Types',Value__c ='.doc,.docx,.csv,.xls,.xlsx,.pdf',Categories__c ='Task Document'));
                SettingList.add(new System_Setting__c ( Name='SOE FIelds',Key__c = 'i8__SOE__c',Value__c ='i8__SOE_Title__c,I8__Summary__c,i8__Baseline_Start__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Task Fields',Key__c = 'i8__Task__c',Value__c ='i8__Task_Title__c,i8__Status__c,i8__ID_Text__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='TeamMember Fields',Key__c = 'i8__Team_Member__c',Value__c ='I8__Member__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='MIS Fields',Key__c = 'i8__MIS__c',Value__c ='I8__MIS_Title__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Dependency Fields',Key__c = 'i8__Dependency__c',Value__c ='I8__Task__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Broadcast Fields',Key__c = 'i8__Broadcast__c',Value__c ='i8__Status__c,I8__All_Users__c,I8__Message__c,I8__Message_End_Date__c,I8__Message_Start_Date__c,I8__This_SOE_Users__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Access Request Line Item Fields',Key__c = 'I8__Access_Request_Line_Item__c',Value__c ='Start_Time__c,End_Time__c,Requested_User__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='TimeSheet Entry Fields',Key__c = 'I8__Timesheet_Entry__c',Value__c ='I8__Start__c,I8__End__c,I8__SOE__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Expenses Fields',Key__c = 'I8__Expenses__c',Value__c ='I8__Date__c,I8__Amount__c,I8__Expense_Type__c,I8__Payment_Type__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='SOE Team Member Fields',Key__c = 'I8__SOE_Team_Member__c',Value__c ='I8__SOE__c,I8__Team_Member__c,I8__Access_Level__c,I8__Role__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Incident Fields',Key__c = 'I8__Incident__c',Value__c ='I8__Summary__c,I8__Inc_Type__c,I8__Priority__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='User Fields',Key__c = 'User',Value__c ='I8__MIS_MyView__c,I8__SOE_MyView__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Member Fields',Key__c = 'I8__Member__c',Value__c ='I8__Salesforce_User__c,I8__Role__c,I8__Phone__c,I8__Email__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Communication Fields',Key__c = 'I8__Communication__c',Value__c ='I8__Completed_Members__c,I8__Milestone_Members__c,I8__Task_Ready_Members__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='MIS Manager Fields',Key__c = 'I8__MIS_Manager__c',Value__c ='I8__MIS__c,I8__MIS_Manager__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Role Fields',Key__c = 'I8__Role__c',Value__c ='I8__Default_SOE_Manager__c,I8__Reference_Role__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Log Fields',Key__c = 'I8__Log__c',Value__c =' Level__c,Source_Class__c,Source_Method__c,Title__c,Description__c,Location__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Access Request Fields',Key__c = 'I8__Access_Request__c',Value__c ='SOE__c,Task__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='TimeSheet Fields',Key__c = 'I8__Timesheet__c',Value__c ='PayPeriod_Start__c,PayPeriod_End__c,Rate_Card_Per_Hour__c,Total_Hours__c,Status__c,Manager__c,Pay_Total__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Expense Claim Fields',Key__c = 'I8__Expense_Claim__c',Value__c ='From_Date__c, To_Date__c, Employee_Name__c,Manager__c,Total_Claim_Amount__c, No_Of_Claims__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='ROTA Fields',Key__c = 'I8__ROTA__c',Value__c ='SOE__c,Team__c,Name__c,Mobile__c,Email__c,Shift_Type__c,Manager_Name__c,Location__c,End_Date__c,Start_Date__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='History Fields',Key__c = 'I8__History__c',Value__c ='SOE__c,Action__c,Task_Id__c,Old_value__c,New_value__c,Field__c,Modified_By__c',Categories__c ='Required Fields'));
                SettingList.add(new System_Setting__c ( Name='Project Budget Fields',Key__c = 'I8__Project_Budget__c',Value__c ='SOE__c,General_Expenses__c,Manpower_Cost__c',Categories__c ='Required Fields'));
                if(Schema.sObjectType.System_Setting__c.isCreateable())
                    insert SettingList;
                             
        }         
    }
}