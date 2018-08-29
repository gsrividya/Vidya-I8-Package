public class AllTasks_Cntrl{
    @AuraEnabled public static ResponseData LoadInitRecords(id soeid, integer limit1){
        ResponseData res ;
        
           Id UserId = String.escapeSingleQuotes(UserInfo.getUserId());
           User CurUser = [select Broadcast__c,SOE_MyView__c from User where id=: UserId ]; 
           string MyView = CurUser.SOE_MyView__c ; 
           Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
           Schema.SObjectType taskSchema = schemaMap.get('I8__Task__c');
           Map<String, Schema.SObjectField> fieldMap = taskSchema.getDescribe().fields.getMap();
           for (String fieldName: fieldMap.keySet()) {
               String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
               Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
               system.debug('----api name ---'+fieldName);
               system.debug('----label---'+fieldLabel);
               system.debug('----datatype ---'+fielddataType );
           }
        
        
         
                res = TaskRecords_Apex (soeid,'all' ,'',limit1,0);
        return res;
    }
    @AuraEnabled public static ResponseData TaskRecords_Apex(id soeid,string stage , string condition ,integer limit1, integer offset1){
        system.debug('--------stage------'+stage);
        system.debug('--------condition------'+condition);
        ResponseData res;
        string query = '',whcondition ='';
        query += 'select id,name,I8__Task_Title__c,I8__Start_Time__c,I8__Status__c,I8__State__c,I8__End_Time__c,I8__Stage__c';
        query+= ',I8__ID_Text__c,I8__Duration__c,I8__Is_Stack__c,I8__End_Stack__c,I8__Team__c,I8__Team__r.Name,I8__Owner__c,I8__Stack_Owner_Name__c';
        query += ',I8__Actual_Start__c,I8__Actual_End__c,I8__Forecast_Start__c,I8__Forecast_End__c,I8__Planned_Start__c,I8__Planned_End__c' ;
        query+= ',I8__Advanced_Notifications__c,I8__Critical_Path__c,I8__Jump__c,I8__Milestone__c,I8__Time_Bound__c,I8__When_Task_Ready__c,I8__Task_Completed__c';
        query+=',I8__Comments__c,I8__Dependency_Type__c,I8__Description__c,I8__Execution_Detail__c,I8__PIN__c,I8__Review_Comments__c,I8__Task_Comments__c,I8__Technical_Detail__c,I8__WalkThrough_Comments__c' ;
        
        query+= ' from I8__Task__c where I8__SOE__c =\''+ soeid+'\'';
        if(stage == 'all')
            whcondition += ' and I8__Stage_Level__c=\'Implementation\'' ;
        else if(stage == 'pre')
            whcondition  += ' and I8__Stage_Level__c=\'Implementation\' and I8__Stage__c = \'Pre\'' ;
        else if(stage == 'imp')
            whcondition += ' and I8__Stage_Level__c=\'Implementation\' and I8__Stage__c = \'Imp\'';
        else if(stage == 'post')
            whcondition += ' and I8__Stage_Level__c=\'Implementation\' and I8__Stage__c =\'Post\'';
        else if(stage == 'backout')
            whcondition += ' and I8__Stage_Level__c=\'BackOut\'' ;
        if(condition == 'readyrunsuspend')
            whcondition += ' and I8__Status__c IN (\'Ready\',\'Run\',\'Suspended\')';
        else if (condition == 'noncompleted')
            whcondition += ' and I8__Status__c != \'Completed\'';
        else if (condition == 'criticalpath')
            whcondition += ' and I8__Critical_Path__c != null';
        else if (condition == 'comms')
            whcondition += ' and (I8__Advanced_Notifications__c = true or I8__Milestone__c = true or I8__When_Task_Ready__c = true or I8__Task_Completed__c = true)';
        else if (condition == 'timebound')
            whcondition += ' and I8__Time_Bound__c != null'; 
        else if (condition == 'broken')
            whcondition += ' and I8__Dependency_Type__c = \'None\''; 
        else if (condition == 'link')
            whcondition += ' and I8__Dependency_Type__c = \'Link\'';
        else if (condition == 'internal')
            whcondition += ' and I8__Dependency_Type__c = \'Internal\''; 
        else if (condition == 'external')
            whcondition += ' and I8__Dependency_Type__c = \'External\'';   
        
        query += whcondition ;
        query += ' order by I8__Id_Before_Decimal__c,I8__Id_After_Decimal__c';
        system.debug('--------query---'+query);
        list<I8__Task__c> TaskList = new list<I8__Task__c>();
        list<I8__Task__c> TaskList1 = new list<I8__Task__c>();
        
        string countquery = 'select count(id) cnt from I8__Task__c where I8__SOE__c =\''+ soeid+'\''+whcondition ;
        AggregateResult[] Results = Database.query(countquery);
        integer RecCount = Integer.valueof(Results[0].get('cnt'));
        system.debug('-------reccount-----'+reccount);
        system.debug('--------offset---'+offset1);
     //   if(offset1 < 2000){ 
            query += ' LIMIT '+limit1+ ' OFFSET '+offset1; 
            system.debug('-----if-------query----'+query);
                TaskList = Database.query(query);
    /*    }

       else{
          system.debug('----------else--query----'+query);
                TaskList1 = Database.query(query);
            integer last ;        
            if(offset1+limit1> TaskList1.Size())
                last = TaskList1.Size() ;
            else
                last = offset1 + limit1;
            for(Integer i=offset1; i< last ;i++)
                TaskList.add(TaskList1[i]);
        }*/
                    
        
                res = new ResponseData(true, TaskList,recCount);
        return res;
    }
      public class ResponseData {
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public list<I8__Task__c> TaskList{ get; set; } 
        @AuraEnabled public integer TotalCount {get;set;}
        public ResponseData(boolean bool, list<I8__Task__c> tasks,integer total){
            this.isSuccess = bool ; this.TasKlist = tasks; this.TotalCount = total ;
        }
    }

}