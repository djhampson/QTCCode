({
    init : function(cmp) {
        let email = cmp.get("v.email"), 
            fname = cmp.get("v.fname"), 
            lname = cmp.get("v.lname"), 
            pass = cmp.get("v.password"), 
            startUrl = cmp.get("v.starturl"),
            accountId = cmp.get("v.accountId"), 
            orgkey = cmp.get("v.orgkey"),
            title = cmp.get("v.title"),
            phone = cmp.get("v.phone"),
            op_url = cmp.get("v.op_url"),
            company = cmp.get("v.company"); 
       
        let action = cmp.get("c.createExternalUser");
        action.setParams(
            { 
                username: email, 
                password: pass, 
                startUrl: startUrl,
                fname: fname, 
                lname: lname,
                accountId: accountId,
                orgkey: orgkey,
                title: title,
                phone: phone,
                company: company
            });

        action.setCallback(this, function(res) {
            if (action.getState() === "SUCCESS") {
                cmp.set("v.op_url", res.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    }, 
    
    login: function(cmp){
        let url = cmp.get("v.op_url"); 
        window.location.href = url;  
    }
})