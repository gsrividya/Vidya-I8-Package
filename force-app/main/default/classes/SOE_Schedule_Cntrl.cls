/* 
Class Name        : SOE_Schedule_Cntrl
Test Class Name   : Test_SOE_Schedule_Cntrl
Purpose/Overview  : To schedule an SOE .
Author            : Purview Ltd.
Code Coverage     : 96%.
Change History    : 
*/
public with sharing class SOE_Schedule_Cntrl{    
    public SOE__C SOE{get;set;}
    public string errormessage{get;set;}
    public boolean errorbool{get;set;}
    public string page{get;set;}
    public integer duration{get;set;}
    public static boolean BoolChanges{get;set;}
    public integer SOE_Duration{get;set;}
    public datetime Change_end_time{get;set;}
    public datetime Change_end_time1{get;set;}
    public I8Constants i8{get;set;}
    public string[] errmsg{get;set;}
    Public boolean review{get;set;}
    Public Map<Id,Id> ImpMgrMap{get;set;}
    Id SOEId;
    
    public SOE_Schedule_Cntrl(){
        page = ApexPages.CurrentPage().getParameters().get('page');
        errmsg = new list<string>();
        i8 = new I8Constants();
        SOEId = ApexPages.CurrentPage().getParameters().get('Id');
        if(Utils.isAccessible('i8__SOE__c')) {
        SOE = [select id,SOE_Title__c,Backout_STage__c,Schedule_Start__c,Schedule_End__c,QA_Review_Required__c,QA_Review__c,Walkthrough__c ,Warning_Zone__c,BAU_Impact__c,Imp_Baseline_End__c,Min_Forecast_Start__c,Imp_Baseline_Start__c,Status__c ,Min_PLanned_Start__C,State__c ,Name,Max_Planned_End__c,Max_Forecast_End__c,Dealy_Ahead_mins__c,Max_End_Time__c from SOE__c where id=:SOEId];
        ImpMgrMap = new Map<Id,Id>();
        if(Utils.isAccessible('i8__SOE_Team_Member__c'))
        for( SOE_Team_Member__c imp : [select Id,Name,Team_Member__r.Salesforce_User__c,Access_Level__c  from SOE_Team_Member__c where SOE__c =: SOE.id  and Access_Level__c = 'Read' ])  
            ImpMgrMap.put(imp.Team_Member__r.Salesforce_User__c,imp.Team_Member__r.Salesforce_User__c);
        If((SOE.QA_Review_Required__c == True && SOE.QA_Review__c != 'Complete') || (SOE.Status__c == i8.STATUS_BUILD)){
            review = True;
            errmsg.add( System.Label.Schedule001);
        }
        else If( SOE.QA_Review__c == 'In Progress' || SOE.Walkthrough__c == 'In Progress'){
            review = True;
            errmsg.add( System.Label.AddTask003);
        }
        else if(ImpMgrMap.containskey(UserInfo.getUserId() ) ){
            review = True;
            errmsg.add( System.Label.AddTask001);
        }
        Else{           
            errormessage =''; 
            errorbool = false;
            if(SOE.Status__c == i8.STATUS_BUILD || SOE.Status__c == i8.STATUS_REVIEW)
                duration  = Integer.valueof((SOE.Imp_Baseline_End__c.getTime() - SOE.Imp_Baseline_Start__c.getTime())/(1000*60));
            else
                duration  = Integer.valueof((SOE.Max_End_Time__c.getTime() - SOE.Min_Forecast_Start__c.getTime())/(1000*60));
            if(duration != 0){            
                if(SOE.Schedule_Start__c != null){           
                    Change_end_time1 = SOE.Schedule_Start__c.addminutes(duration);
                    date mydate = Date.newInstance(Change_end_time1.year(),Change_end_time1.month(),Change_end_time1.day());
                    time mytime = time.newInstance(Change_end_time1.hour(),Change_end_time1.minute(),Change_end_time1.second(),Change_end_time1.millisecond());
                    Change_end_time = DateTime.newInstancegmt(myDate, myTime);
                }            
            }        
            BoolChanges = false;
        }
        }else { review = true; errmsg.add( System.Label.ADMIN001);}
    }   
    public pagereference Apply(){ 
        errorbool = false; 
        errmsg.clear();   
        if(Utils.isUpdateable('i8__SOE__c')){
            Savepoint sp = Database.setSavepoint();
            try{
            change_end();
            if(SOE.Schedule_Start__c == null){  
                errmsg.add( System.Label.Schedule002);
                errorbool = true;          
            }else if(SOE.Schedule_Start__c <= system.now()){ 
                errmsg.add( System.Label.Schedule004);
                errorbool = true;               
            }   
            if(SOE.Schedule_End__c == null ){  
                errmsg.add(System.Label.Schedule003);
                errorbool = true;  
            }
            if(SOE.Schedule_End__c < Change_end_time1 ){  
                errmsg.add(System.Label.Schedule005);
                errorbool = true;  
            }
            if(SOE.BAU_Impact__c == null){          
                errmsg.add(System.Label.Schedule006);      
                errorbool = true;           
            }
            if(SOE.Schedule_Start__c != null && SOE.Schedule_End__c != null && SOE.Schedule_Start__c >= SOE.Schedule_End__c){  
                errmsg.add(System.Label.Schedule007);
                errorbool = true;              
            }        
            if(SOE.BAU_Impact__c != null && SOE.Schedule_Start__c != null && SOE.Schedule_End__c != null && SOE.Warning_Zone__c == null){
                SOE.Warning_Zone__c = SOE.BAU_Impact__c;            
            } 
            if(SOE.Warning_Zone__c != null && SOE.Schedule_End__c != null && SOE.Schedule_End__c > SOE.Warning_Zone__c){  
                errmsg.add(System.LAbel.Schedule008);
                errorbool = true;              
            } 
            if(SOE.BAU_Impact__c != null && SOE.Schedule_End__c != null && SOE.Schedule_End__c > SOE.BAU_Impact__c){ 
                errmsg.add(System.Label.Schedule009);
                errorbool = true;             
            }
            if(SOE.BAU_Impact__c != null && SOE.Warning_Zone__c != null && SOE.Warning_Zone__c > SOE.BAU_Impact__c){ 
                errmsg.add(System.Label.Schedule010);
                errorbool = true;           
            }              
            if(errorbool == false  ){ 
                SOE_duration = integer.valueof((SOE.Schedule_End__c.GetTime()-SOE.Schedule_Start__c.GetTime())/(1000*60));           
                if(SOE.Status__c == i8.STATUS_REVIEW)
                    SOE.Status__c =  i8.STATUS_SCHEDULED ; 
                if(Utils.isUpdateable('i8__SOE__c'))            
                    update SOE;            
                BoolChanges = true;
                Task_triggerHandler.UpdateAllTasks(new list<string>{SOE.Id},i8.CONTEXT_IMP); 
                if(SOE.Backout_STage__c == true)
                    Task_TriggerHandler.UpdateAllTasks(new list<string>{SOE.Id},i8.CONTEXT_BO);
                if(page == 'detail')   
                    return new pagereference('/'+SOE.id);
                else 
                    return new pagereference('/apex/AllTasks_ClientSide?id='+SOE.id);
            }
            }
            catch(Exception e){
                       Database.rollback(sp);
                       LogFactory.error('SOE_Schedule_Cntrl', 'Apply', '', e.getMessage() + '' + e.getStackTraceString());  
                       LogFactory.SaveLog(); 
                       errorbool = true; 
                       errormessage= e.getMessage();                  
                }
        } else {errorbool = true;errormessage = System.Label.ADDTASK007;}
        return null; 
    }
    public PageReference change_end() {         
        if(duration != 0 && SOE.Schedule_Start__c != null){  
            if(SOE.Schedule_Start__c != null){                 
                Change_end_time1 = SOE.Schedule_Start__c.addminutes(duration);
                date mydate = Date.newInstance(Change_end_time1.year(),Change_end_time1.month(),Change_end_time1.day());
                time mytime = time.newInstance(Change_end_time1.hour(),Change_end_time1.minute(),Change_end_time1.second(),Change_end_time1.millisecond());
                Change_end_time = DateTime.newInstancegmt(myDate, myTime);
            }
        }        
        return null;
    }
     public pagereference Cancel(){
        if(page == 'detail'){
            if(UserInfo.getUiThemeDisplayed() == 'Theme3')
                return new PageReference('javascript:window.close()');
            else
                return new pagereference('/'+SOEId);
        }
        else
            return new pagereference('/apex/AllTasks_ClientSide?id='+SOEId);
    }
}