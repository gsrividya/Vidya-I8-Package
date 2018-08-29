({
    doInit : function(component, event, helper) {
        helper.LoadInitRecords_Helper(component);
        component.set("v.CurrentCoulmns" , component.get("v.MainCoulmns")) ;
        component.set("v.CurrentFields" , component.get("v.MainFields")) ;
        component.set("v.CurrentDatatypes" , component.get("v.MainDatatypes")) ;
    },
    getTaskRecords : function(cmp,event,helper){
        var params = event.getParam('arguments');
        cmp.set("v.StageLevel" , params.param1);
        cmp.set( "v.Condition" , params.param2);
        var cond = params.param2 ;
        if (cond == 'description' || cond == 'plannedforecastactual' || cond == 'summary' || cond == 'qa' || cond == 'walkthrough' || cond == 'mainview' )
            helper.ViewChange_Helper(cmp,cond);
        else if( cond == 'myview'){
            component.set("v.CurrentCoulmns" , component.get("v.MyCoulmns")) ;
            component.set("v.CurrentFields" , component.get("v.MyFields")) ;
            component.set("v.CurrentDatatypes" , component.get("v.MyDataTypes")) ;
        }
            else  
                helper.TaskRecords_Helper(cmp) ;
    },
    NextPage : function(cmp,event, helper){
        var PageNo = cmp.get("v.PageNo");
        var offset = PageNo * cmp.get("v.PageSize");
        PageNo++;
        cmp.set("v.PageNo",PageNo) ;
        cmp.set("v.Offset",offset) ;
        helper.TaskRecords_Helper(cmp); 
    },
    FirstPage : function(cmp,event, helper){
        cmp.set("v.PageNo",1) ;
        cmp.set("v.Offset",0) ;
        helper.TaskRecords_Helper(cmp); 
    },
    LastPage : function(cmp,event, helper){
        cmp.set("v.PageNo",cmp.get("v.TotalPages")) ;
        var offset = (cmp.get("v.PageNo") -1)  * cmp.get("v.PageSize");
        cmp.set("v.Offset",offset) ;
        helper.TaskRecords_Helper(cmp); 
    },
    PrevPage : function(cmp,event, helper){
        var PageNo = cmp.get("v.PageNo");
        PageNo--;
        cmp.set("v.PageNo",PageNo) ;
        var offset = (PageNo -1)  * cmp.get("v.PageSize");
        cmp.set("v.Offset",offset) ;
        helper.TaskRecords_Helper(cmp); 
    },
    
})