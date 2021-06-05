({
	getBaseUrl : function (component) {
        var action = component.get('c.getBaseUrl')
        action.setCallback(this, function (response) {
            var state = response.getState()
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue()
                component.set('v.baseUrl', result)
            }
        })
        $A.enqueueAction(action)
    }
})