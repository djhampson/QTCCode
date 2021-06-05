({
    init : function(component, event, helper) {

        var action = component.get("c.getCase");
        action.setParams({"recordId": component.get("v.recordId")});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state == "SUCCESS"){
                var c = response.getReturnValue();
                component.set("v.case", c);
                window.setTimeout(
                    $A.getCallback(function () {

                    })
                );

            } else {
                console.log('There was a problem : '+response.getError());
            }
        });
        $A.enqueueAction(action);

	},
    
	handleOpenInNewWindow : function(component, event, helper) {
        var theUrl = component.get('v.theurl');
        //theUrl = theUrl.replace("baseURLtoreplace", component.get("v.baseUrl"));
        //var vbaseURL = component.get("v.baseUrl");
        //if(vbaseURL.contains('customercommunity')){
        //    theUrl = theUrl.replace("baseURLtoreplace", component.get("v.baseUrl") + '/T1Employees') ;
        //}
        //else {
            theUrl = theUrl.replace("baseURLtoreplace", component.get("v.baseUrl"));
        //}
        window.open(theUrl, '_blank', "height=520,width=450");
    }
})