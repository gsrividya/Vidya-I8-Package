({
    LoadInitRecords_Helper : function(component) {
        var action = component.get("c.LoadInitRecords");
        action.setParams({
            "soeid" : component.get("v.SOEId"), 
            "limit1" : component.get("v.PageSize"), 
        });
        action.setCallback(this,function(response){
            var resp = response.getReturnValue();
            if(component.isValid() && action.getState() == "SUCCESS" && resp.isSuccess == true){              
                component.set("v.TaskList" , resp.TaskList);
                component.set("v.TotalCount" , resp.TotalCount);
                var tpages = Math.ceil(resp.TotalCount / component.get("v.PageSize"));
                component.set("v.TotalPages" , tpages);
            }
            else{
                alert('error');
            }
        });
        $A.enqueueAction(action);
        
    },
    TaskRecords_Helper : function(component) {
        var action = component.get("c.TaskRecords_Apex");
        action.setParams({
            "soeid" : component.get("v.SOEId"),
            "stage" : component.get("v.StageLevel"),
            "condition" : component.get("v.Condition"),
            "limit1" : component.get("v.PageSize"),
            "offset1" : component.get("v.Offset"),
        });
        action.setCallback(this,function(response){
            var resp = response.getReturnValue();
            if(component.isValid() && action.getState() == "SUCCESS" && resp.isSuccess == true){              
                component.set("v.TaskList" , resp.TaskList);
                component.set("v.TotalCount" , resp.TotalCount);
                var tpages = Math.ceil(resp.TotalCount / component.get("v.PageSize"));
                component.set("v.TotalPages" , tpages);
                // alert(JSON.stringify(resp.TaskList));
            }
            else{
                alert('error');
            }
        });
        $A.enqueueAction(action);
        
    },
    ViewChange_Helper : function(cmp,condition){
        var columns = cmp.get("v.MainCoulmns") ;
        var fields = cmp.get("v.MainFields") ;
        var types = cmp.get("v.MainDatatypes") ;
        var count = 0;
        if(condition == 'description'){         
            columns.push('Stack Description') ;
            fields.push('I8__Description__c') ;
            types.push('TEXTAREA');
            count = 1;
        }
        else if(condition == 'plannedforecastactual'){         
            columns.push('Planned Start') ;
            fields.push('I8__Planned_Start__c') ;
            columns.push('Planned End') ;
            fields.push('I8__Planned_End__c') ;
            columns.push('Forecast Start') ;
            fields.push('I8__Forecast_Start__c') ;
            columns.push('Forecast End') ;
            fields.push('I8__Forecast_End__c') ;
            columns.push('Actual Start') ;
            fields.push('I8__Actual_Start__c') ;
            columns.push('Actual End') ;
            fields.push('I8__Actual_End__c') ;
            for (var i=0; i< 6; i++)
                 types.push('DATETIME');
            count = 6;
        }
        if(condition == 'summary'){         
            columns.push('Technical Summary') ;
            fields.push('I8__Technical_Detail__c') ;
            types.push('TEXTAREA');
            count = 1;
        }
        if(condition == 'qa'){         
            columns.push('Review Comments') ;
            fields.push('I8__Review_Comments__c') ;
             types.push('TEXTAREA');
            count = 1;
        }
        if(condition == 'walkthrough'){         
            columns.push('Walkthrough Comments') ;
            fields.push('I8__WalkThrough_Comments__c') ;
            types.push('TEXTAREA');
            count = 1;
        }
        cmp.set("v.CurrentCoulmns" , columns) ;
        cmp.set("v.CurrentFields" , fields) ;
        cmp.set("v.CurrentDatatypes" , types) ;
        columns.splice( (columns.length)-count ,count);
        fields.splice((fields.length)-count,count);
        types.splice((types.length)-count,count);
    }
})