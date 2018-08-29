/* 
Class Name        : SOE_MyView_cntrl
Test Class Name   : Test_SOE_MyView_cntrl
Purpose/Overview  : To change the columns that are displayed in All Tasks page.
Author            : Purview Ltd.
Code Coverage     : 95%.
Change History    : 
*/
public with sharing class SOE_MyView_cntrl{
    public list<String> leftselected {get;set;}
    Public User curUser{get;set;}
    public string view {get; set;}
    public string soeid {get;set;}
    public list<String> Rightselected {get;set;}
    public list<string> leftlist {get;set;}
    public list<string> rightlist{get;set;}
    public Map<string,Schema.SObjectField> colMap{get;set;}
    public boolean soe{get;set;}
    public string  statusmsg{get;set;} 
    
    Map<String, Schema.SObjectField> fieldMap{get;set;}
    public SOE_MyView_cntrl(){
        statusmsg=null;
        leftselected = new list<string>();
        Rightselected = new list<String>();
        leftlist = new list<string>();
        rightlist =  new list<string>();
        colMap = new map<string,Schema.SObjectField>();
        soeid = ApexPages.CurrentPage().getParameters().get('Id');
        if(Utils.isAccessible('User')){
        curUser = [select id,Name,email,SOE_MyView__c,MIS_MyView__c from user where id =: userinfo.getuserid()];
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ObjectSchema = schemaMap.get('I8__task__c');
        fieldMap = ObjectSchema.getDescribe().fields.getMap();
        for(String fieldName : fieldMap.keySet()) {           
            if( fieldName =='I8__Actual_Duration__c'|| fieldName =='I8__WalkThrough_Comments__c' || fieldName =='I8__Technical_Skills__c'|| fieldName =='I8__Actual_End__c'|| fieldName =='I8__Actual_Start__c'|| fieldName =='I8__Description__c'|| fieldName =='I8__Duration__c'|| fieldName =='I8__End_Time__c'|| fieldName =='I8__Start_Time__c'||
               fieldName =='I8__Forecast_Duration__c'|| fieldName =='I8__Forecast_End__c'||fieldName =='I8__Forecast_Start__c'||fieldName =='I8__Planned_Duration__c' || fieldName =='I8__Planned_Start__c'|| fieldName =='I8__Planned_End__c'|| fieldName =='I8__Jumped__c'|| fieldName =='I8__Jumped_Duration__c'|| 
               fieldName =='I8__Review_Comments__c'||   fieldName =='I8__Task_Comments__c'|| fieldName =='I8__Technical_Detail__c'|| fieldName =='I8__Time_Bound__c' || fieldName =='I8__Team__c' || fieldName =='I8__Task_Title__c' || fieldName =='I8__ID_Text__c' || fieldName == 'I8__Stack_Owner_Name__c'){
                   colMap.put(Schema.getGlobalDescribe().get('I8__task__c').getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel(),fieldMap.get(fieldName));
                   leftlist.add(Schema.getGlobalDescribe().get('I8__task__c').getDescribe().fields.getMap().get(fieldName).getDescribe().getLabel());
               }
        }
        List<String> SplitList = new list<string>();
        if(soeid.substring(0,3) == SOE__c.sobjecttype.getDescribe().getKeyPrefix() && curUser.SOE_MyView__c != null){
            SplitList = curUser.SOE_MyView__c.split(',');
            soe = true;
        }
        if(soeid.substring(0,3) == MIS__c.sobjecttype.getDescribe().getKeyPrefix() &&  curUser.MIS_MyView__c != null){
            SplitList = curUser.MIS_MyView__c.split(',');
            soe = false;
        }
        if(SplitList.size()>0){
            for(string s : SplitList){
                if(s != null){
                    rightlist.add(Schema.getGlobalDescribe().get('I8__Task__c').getDescribe().fields.getMap().get(s).getDescribe().getLabel());
                    for(integer i=0;i<leftlist.size();i++){
                        if(Schema.getGlobalDescribe().get('I8__task__c').getDescribe().fields.getMap().get(s).getDescribe().getLabel()==leftlist[i]){
                            leftlist.remove(i);
                        }
                    }
                }
            }
        }
        for(string s : rightlist){
            for(integer i=0;i<leftlist.size();i++){
                if(s==leftlist[i]){
                    leftlist.remove(i);   
                }          
            } 
        }
      }else{statusmsg = System.Label.ADMIN001;}
    }
    public list<selectoption> getObjectFields(){
        list<selectoption> options = new list<selectoption>();
        for(String s : leftlist) {
            options.add(new selectoption(s,s));
        }
        return options;
    }   
    public list<selectoption> getrightFields() {
        list<SelectOption> RightList1 = new list<SelectOption>();
        for(string s : rightlist){
            RightList1.add(new selectoption(s,s));
        }
        return RightList1;
    }
    public pagereference AddFields() {
        if(leftselected.size()>0){
            rightlist.addAll(leftselected);
            for( integer i=0; i<LeftList.Size(); i++){
                for(string j: leftselected){
                    if(LeftList[i] == j)
                        LeftList.remove(i);
                }
            }
        }
        return null;
    }
    public void removefields(){
        if(RightSelected.size()>0){
            LeftList.addAll(RightSelected);
            for( integer i=0; i<rightlist.Size(); i++){
                for(string j: RightSelected){
                    if(rightlist[i] == j)
                        rightlist.remove(i);
                }
            }
        }
    }
    public pagereference save(){
      Savepoint sp = Database.setSavepoint();
        try{
         if(Utils.isUpdateable('User')) {
            view ='';
        for(integer i=0;  i < rightlist.size();i++){
            view+=colMap.get(rightlist[i]);
            if(rightlist.size()-1 != i) 
                view+=',';
        }
        if(soeid.substring(0,3) == SOE__c.sobjecttype.getDescribe().getKeyPrefix()){
            curuser.SOE_MyView__c = view;
            if(Utils.isUpdateable('User'))
                update curuser;
            return new pagereference('/apex/AllTasks_ClientSide?id='+SOEId);
        }
        else if(soeid.substring(0,3) == MIS__c.sobjecttype.getDescribe().getKeyPrefix()){
            curuser.MIS_MyView__c = view;
            if(Utils.isUpdateable('User'))
                update curuser;
            return new pagereference('/apex/MIS_AllTasks?id='+SOEId);
         }
        }else{statusmsg = System.Label.AddTask007;}
       }
       catch(Exception e){
                   Database.rollback(sp);
                   LogFactory.error('SOE_MyView_cntrl', 'saveMethod', '', e.getMessage() + '' + e.getStackTraceString());  
                   LogFactory.SaveLog(); 
                   statusmsg = e.getMessage();                  
       } 
        return null;
    }
    public pagereference Cancel(){
        if(soeid.substring(0,3) == SOE__c.sobjecttype.getDescribe().getKeyPrefix())
            return new pagereference('/apex/AllTasks_ClientSide?id='+SOEId);
        else if(soeid.substring(0,3) == MIS__c.sobjecttype.getDescribe().getKeyPrefix())
            return new pagereference('/apex/MIS_AllTasks?id='+SOEId);
        return null;
    }
}