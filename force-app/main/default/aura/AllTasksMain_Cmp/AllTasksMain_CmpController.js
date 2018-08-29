({
    doInit : function(cmp, event, helper) {
        var items = [
            {
                "label": "1. Stages",
                "name": "1",
                "items": [{
                    "label": "1.1 Pre Implementation",
                    "name": "pre",
                    "expanded": true,                
                },
                          {
                              "label": "1.2 Implementation",
                              "name": "imp",
                              "expanded": true,                
                          },{
                              "label": "1.3 Post Implementation",
                              "name": "post",
                              "expanded": true,                
                          },{
                              "label": "1.4 All Implementations",
                              "name": "all",
                              "expanded": true,                
                          },{
                              "label": "1.5 Backout",
                              "name": "backout",
                              "expanded": true,                
                          }]
            },
            {
                "label": "2. Views",
                "name": "2",
                "items": [{
                    "label": "2.1 Main View",
                    "name": "mainview",
                    "expanded": true,                
                },
                          {
                              "label": "2.2 My View",
                              "name": "myview",
                              "expanded": true,                
                          },{
                              "label": "2.3 Planned, Forecast & Actual Times",
                              "name": "plannedforecastactual",
                              "expanded": true,                
                          },{
                              "label": "2.4 Stack Description",
                              "name": "description",
                              "expanded": true,                
                          },{
                              "label": "2.5 Technical Summary",
                              "name": "summary",
                              "expanded": true,                
                          },{
                              "label": "2.6 QA Review Comments",
                              "name": "qa",
                              "expanded": true,                
                          },{
                              "label": "2.7 Walkthrough Comments",
                              "name": "walkthrough",
                              "expanded": true,                
                          }]
            },
            {
                "label": "3. Actions",
                "name": "3",
                "items": [{
                    "label": "3.1 Ready, Run, & Suspended Tasks",
                    "name": "readyrunsuspend",
                    "expanded": true,                
                },
                          {
                              "label": "3.2 Non Completed Tasks",
                              "name": "noncompleted",
                              "expanded": true,                
                          },{
                              "label": "3.3 Critical Path Tasks",
                              "name": "criticalpath",
                              "expanded": true,                
                          },{
                              "label": "3.4 Milestones & Comms Tasks",
                              "name": "comms",
                              "expanded": true,                
                          },{
                              "label": "3.5 Timebound Tasks",
                              "name": "timebound",
                              "expanded": true,                
                          },]
                          },
                          {
                          "label": "4. Dependency",
                          "name": "4",
                          "items": [{
                          "label": "4.1 Broken Tasks",
                          "name": "broken",
                          "expanded": true,                
                          },
                          {
                          "label": "4.2 Link Tasks",
                          "name": "link",
                          "expanded": true,                
                          },{
                          "label": "4.3 Internal Dep Tasks",
                          "name": "internal",
                          "expanded": true,                
                          },{
                          "label": "4.4 External Dep Tasks",
                          "name": "external",
                          "expanded": true,                
                          },]
            }
        ];
        cmp.set('v.NavigationItems', items);
    },
    OpenNavigationMenu : function( component,event,helper){
        if(component.get("v.ShowMenu") == false)
            component.set("v.ShowMenu" , true);
        else
            component.set("v.ShowMenu" , false);
        if(component.get("v.ShowMenu") == true) {
            var down1 = component.find("table"); 
            $A.util.removeClass(down1,'slds-medium-size--12-of-12');
            $A.util.addClass(down1,'slds-medium-size--9-of-12');
            var down2 = component.find("leftmenu"); 
            $A.util.removeClass(down2,'slds-hide');
            $A.util.addClass(down2,'slds-show');
        }
        else{
            var down1 = component.find("table"); 
            $A.util.removeClass(down1,'slds-medium-size--9-of-12');
            $A.util.addClass(down1,'slds-medium-size--12-of-12');
            var down2 = component.find("leftmenu"); 
            $A.util.removeClass(down2,'slds-show');
            $A.util.addClass(down2,'slds-hide');
        }
    },
    NavigationMenuSelect: function (cmp, event) {
        event.preventDefault();   
        cmp.set('v.selected', event.getParam('name'));
        var tasktable = cmp.find("tasktable");
        var selected = event.getParam('name') ;
        
        if(selected == 'pre' || selected == 'imp' || selected == 'post' || selected == 'all' || selected == 'backout') {
            cmp.set("v.StageLevel" , selected );
            cmp.set("v.Condition" , undefined );
        }
        else
            cmp.set("v.Condition" , selected );
        tasktable.taskTableRefresh(cmp.get("v.StageLevel") ,cmp.get("v.Condition"));
        
    },
    ResetConditions : function(cmp,event,helper){
        cmp.set("v.StageLevel" , 'all' );
        cmp.set("v.Condition" , undefined );
        var tasktable = cmp.find("tasktable");
        tasktable.taskTableRefresh(cmp.get("v.StageLevel") ,cmp.get("v.Condition"));
    }
})