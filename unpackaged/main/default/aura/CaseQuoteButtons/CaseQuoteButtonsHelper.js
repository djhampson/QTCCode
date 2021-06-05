({
	helperMethod : function() {
		
	},
    
    dismissErrorMessages : function (component) {
        component.set('v.hasError', false);
        component.set('v.errorMessage', '');
    }
})