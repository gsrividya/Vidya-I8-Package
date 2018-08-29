/* 
Class Name        : Rota_Cntrl 
Test Class Name   : Test_Rota_Cntrl
Purpose/Overview  : To dislay ROTA records that which resources are working 
Author            : Purview Ltd.
Code Coverage     : 100%
Change History    : 

*/
public with sharing class Rota_Cntrl {
    public list<ROTA__c> RotaList { get;set;}
    public id Soeid{get;set;}
    public list<SOE__c>  MISSOE_list{get;set;}    
    public Set<Id> SOEIds{get;set;}
    public string SOEIdstring{get;set;}
    Public Boolean SOE{get;set;}
    public string errmsg {get;set;}
    
    public Rota_Cntrl(){
        Soeid = apexpages.currentpage().getparameters().get('id'); 
        SOEIds = new set<id>();      
        SOEIdstring = string.valueof(Soeid);        
        if(SOEIdstring.substring(0,3) == SOE__c.sobjecttype.getDescribe().getKeyPrefix()){
            SOE = True;
            SOEIds.add(SOEID); 
        }
        else if(SOEIdstring.substring(0,3) == MIS__c.sobjecttype.getDescribe().getKeyPrefix()){
            SOE = False;
            if(Utils.isAccessible('i8__MIS__c'))
                MISSOE_list=[select id,MIS__c from SOE__c where MIS__c=:SOEID];            
            for(SOE__c MISESOE : MISSOE_list)
                SOEIds.add(MISESOE.id); 
        }
        if(Utils.isAccessible('i8__ROTA__c'))
         RotaList = RotaList = [select id,name,Name__c,Team__c,Email__c,Desk_Phone__c,Mobile__c,Location__c,Secondary_Name__c,Secondary_Team__c,Secondary_Team__r.name,Secondary_Mobile__c,Secondary_DeskPhone__c,Secondary_Mail__c,Manager_Name__c,Manager_Email__c,Manager_Mobile__c,
               Manager_DeskPhone__c,Shift_Type__c,Start_Date__c,SOE__c,SOE__r.name,End_Date__c,Vendor__c,Application__c,Comments__c,No_of_Hours__c from ROTA__C where SOE__c IN: SOEIds];
        else
            errmsg = System.Label.ADMIN001; 
    }  
    public pagereference CancelTask(){          
        if(SOE == False )
            return new pagereference ('/apex/MIS_AllTasks?id='+SOEId);  
        else  
            return new pagereference ('/apex/AllTasks_ClientSide?id='+SOEId);
    }
}