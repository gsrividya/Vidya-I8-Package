/* 
Class Name        : List_incidents_cntrl 
Test Class Name   : Test_view_all_incidents
Purpose/Overview  : To display all Incidents for an SOE  
Author            : Purview Ltd.
Code Coverage     : 100%
Change History    : 

*/
public with sharing class List_incidents_cntrl {
    public Incident__c edit_incedent {set;get;}
    public Map<Id,Incident__c> incList {get;set;}
    public string incstatus{get;set;}
    public id SOEID {get;set;}
    public id MISID {get;set;}
    public id incid {get;set;}
    Public boolean PB {get;set;}
    Public boolean PB1 {get;set;}
    public I8Constants i8{get;set;}
    public string errormessage{get;set;}
    public Set<Id> SOEIds ;
    public boolean error{get;set;}
    Public Boolean SOE{get;set;}
    Public Map<Id,Id> ImpMgrMap{get;set;}
    public string ImpMgrMapKey{get;set;}
    public string status;
    Boolean Incident_Access;
    
    public List_incidents_cntrl(){
        Incident_Access = Utils.isAccessible('i8__Incident__c');
        edit_incedent = new Incident__c();    
        i8 = new I8Constants();
        SOEID = Apexpages.currentPage().getParameters().get('id');
        MISID = Apexpages.currentPage().getParameters().get('Mid');
        incstatus= ApexPages.currentPage().getParameters().get('status');
        PB = False;
        PB1 = False;
        ImpMgrMap = new Map<Id,Id>();
        if(SOEID != null)
            SOE = True;
        else
            SOE = False; 
        list<string> RolesLIst = System.Label.Roles_To_Edit_SOE.split(','); 
        RolesList.add('Incident Manager');
        if(Incident_Access){
        if(Utils.isAccessible('i8__SOE_Team_Member__c'))
            for( SOE_Team_Member__c imp : [select Id,Name,Team_Member__r.Salesforce_User__c,Access_Level__c  from SOE_Team_Member__c where SOE__c =: SOEId  and (Access_Level__c = 'Edit' or Access_Level__c = 'All' )and Role__r.Reference_Role__c  IN : RolesLIst])  
                ImpMgrMap.put(imp.Team_Member__r.Salesforce_User__c,imp.Team_Member__r.Salesforce_User__c);
        if(MISID != null && Utils.isAccessible('i8__MIS_Manager__c'))
            for(MIS_Manager__c mis: [select id,MIS_Manager__c from MIS_Manager__c where MIS__c =: MISID])
                ImpMgrMap.put(mis.MIS_Manager__c ,mis.MIS_Manager__c );
        if(Schema.SOBjectTYpe.Profile.isAccessible())
            if([Select Id,Name from Profile where Id=:userInfo.getProfileId()].Name == 'System Administrator')
                ImpMgrMap.put(userInfo.getUserId(),userInfo.getUserId());
        ImpMgrMapKey = string.valueof(ImpMgrMap.keyset()).replace('{', '').replace('{', ''); 
        SOEIds = New Set<Id>();
        if(Utils.isAccessible('i8__SOE__c'))    
            for(SOE__c MIS_SOE : [Select Id,MIS__c from SOE__c where MIS__c =: MISID and MIS__c != null])
                SOEIds.add(MIS_SOE.id); 
        if(SOEID != null)
            SOEIds.add(SOEId);
        getRecords();
        }else{ errormessage = System.Label.ADMIN001;}
      }
      public void getRecords(){
           if(Incident_Access){
            if(incstatus == null)
                    incList = new Map<Id,Incident__c>([select id,Name,Notes__c,Priority__c,Service__c,SOE1__c,Inc_Close_Time__c,Resolution_Type__c,Impact_Analysis__c,MIS__c,
                               SOE1__r.QA_Review__c,SOE1__r.WalkThrough__c,Status__c,Summary__c,Target_Date__c,Task__c,Task__r.ID_Text__c,Urgency__c,Inc_Open_Time__c,
                               Risk_Mitigation__c,INC_on_Object__c,Assignee__c,Conference_Audio_Number__c,Incident_Manager__c,Root_Cause__c,CI__c,Inc_Type__c,Company__c,Contact__c,Customer__c,Impact__c,
                               Technical_Recommendation__c from Incident__c where SOE1__c IN : SOEIds or (MIS__c =: MISID and MIS__C != null)]);        
                else
                    incList = new Map<id,Incident__c>([select id,Name,Notes__c,Priority__c,Service__c,SOE1__c,Inc_Close_Time__c,Resolution_Type__c,Impact_Analysis__c,MIS__c,
                               SOE1__r.QA_Review__c,SOE1__r.WalkThrough__c,Status__c,Summary__c,Target_Date__c,Task__c,Task__r.ID_Text__c,Urgency__c,Inc_Open_Time__c,
                               Risk_Mitigation__c,INC_on_Object__c,Assignee__c,Conference_Audio_Number__c,Incident_Manager__c,Root_Cause__c,CI__c,Inc_Type__c,Company__c,Contact__c,Customer__c,Impact__c,
                               Technical_Recommendation__c from Incident__c where (SOE1__c IN : SOEIds or (MIS__c =: MISID and MIS__C != null)) and Status__c =:incstatus]); 
           }                    
    }   
    public PageReference edit_inc() {
        edit_incedent = incList.get(incid);
        status = edit_incedent.Status__c;
        PB = True;
        PB1 = False;
        error = false ;
        return null;
    }
    public PageReference edit_inc1() {
        edit_incedent = incList.get(incid);
        status = edit_incedent.Status__c;
        PB = False;
        PB1 = True;
        error =false;
        return null;
    }    
    public PageReference cancel() {
        incid = null;
        error = false;
        PB= false;
        PB1 = false; 
        getREcords();       
        return null;
    }
    public PageReference save_inc() {  
        error = false;  errormessage  = null;
        Savepoint sp = Database.setSavepoint();
        try{
           if(Utils.isUpdateable('i8__Incident__c') && Utils.isAccess_Update('I8__Task__c')){
            if(edit_incedent.Resolution_Type__c == null && edit_incedent.Inc_Type__c=='Suspended' && edit_incedent.status__c=='Closed'){
                error = true;
                errormessage = System.Label.ListIncident001+'\n';
            }
            if(edit_incedent.Root_Cause__c== null && edit_incedent.Inc_Type__c=='Suspended' && edit_incedent.status__c=='Closed'){
                error = true;
                errormessage = System.Label.ListIncident002;
            }
            if(error == false){                        
                    If( STatus  != 'Closed' && edit_incedent.Status__c == 'Closed'){
                        edit_incedent.Inc_Close_Time__c = system.now();                
                        if(edit_incedent.Inc_Type__c  == i8.STATUS_SUSPENDED && edit_incedent.INC_on_Object__c == 'Task' ){
                            Task__c tas = [select id,Status__c from Task__c where id=: edit_incedent.Task__c];
                            if(tas != null && tas.Status__c == i8.STATUS_SUSPENDED){
                                tas.Status__c = 'ReRun';
                                LogFactory.info('List_Incidents_Cntrl', 'Save_Inc', 'Task', JSON.serialize(tas), 'Line - 111'); 
                                if(Utils.isUpdateable('i8__Task__c'))
                                    update tas;
                             }
                        }                 
                    }
                    LogFactory.info('List_Incidents_Cntrl', 'Save_Inc', 'Incident', JSON.serialize(edit_incedent), 'Line - 117'); 
                    if(Utils.isUpdateable('i8__INcident__c'))
                            update edit_incedent;
                    PB= false;
                    PB1 = true; 
                    error = false;    
                    getRecords();      
                    incid = null;             
            }else
                getRecords();
           }else{errormessage = System.Label.AddTask007;}     
        }catch(Exception e){
                    Database.rollback(sp);
                    LogFactory.error('List_Incidents_Cntrl', 'Save_Inc', '', e.getMessage() + '' + e.getStackTraceString());                    
                    error = true;
                    errormessage = e.getMessage();                  
        }
        LogFactory.SaveLog(); 
        return null;        
    }
    public pagereference CancelIncidents(){
        if(SOE == true)
            return new pagereference('/apex/AllTasks_ClientSide?id='+SOEId);
        else
            return new pagereference('/apex/MIS_AllTasks?id='+MISID);
            
    }
}