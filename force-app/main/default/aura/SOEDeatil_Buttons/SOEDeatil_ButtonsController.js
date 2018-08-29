({
	OpenTasksApplication : function(component, event, helper) {
		window.open('/I8/AllTasks_App.app?SOEId='+component.get("v.recordId"),'_blank');
	}
})