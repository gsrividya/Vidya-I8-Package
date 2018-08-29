/* 
Class Name        : Broadcast_New_Cntrl 
Test Class Name   : Test_Broadcast_New_Cntrl
Purpose/Overview  : To insert Broadcast message from SOE-All TasksConsole
Author            : Purview Ltd.
Code Coverage     : 100%
Change History    : 

*/
public with sharing class Broadcast_New_Cntrl {
    public BroadCast__c bc {get;set;}
    Public id SOEId{get;set;}
    public Boolean error{get;set;}
    public String errorMessage{get;set;}
    public Broadcast_New_Cntrl (){
        error=false;
        SOEId = apexPages.CurrentPage().getparameters().get('id');
         if(Utils.isCreateable('i8__BroadCast__c')){
        bc = new BroadCast__c();
        bc.Status__c = 'Active'; 
        }else {  errormessage = System.LABEL.AddTASK006;error = true;}       
    }   
    public pagereference Save(){
        Savepoint sp = Database.setSavepoint();
        try{
            if(Utils.isCreateable('I8__BroadCast__c')){
                if(bc.This_SOE_Users__c== true)
                    bc.SOE__c = SOEId;
                LogFactory.info('Broadcast_New_Cntrl ', 'SaveMethod', 'Broadcast', JSON.Serialize(bc),'Line - 26');  
                LogFactory.SaveLog();            
                if(UTils.isCReateable('i8__Broadcast__c'))
                    insert bc;
                return new pagereference('/apex/AllTasks_ClientSide?id='+SOEId);
            }
            else { errorMessage = System.Label.AddTask006; error = true; }
            return null;
        }
        catch(DMLException e)
        {
            errorMessage = e.getDmlMessage(0);
            error = true;
            Database.rollback(sp);
            LogFactory.error('Broadcast_New_Cntrl ', 'SaveMethod', '', e.getMessage() + '' + e.getStackTraceString());  
            LogFactory.SaveLog(); 
            return null;
        }        
    }
    public pagereference Cancel(){
        return new pagereference('/apex/AllTasks_ClientSide?id='+SOEId);
    }
}