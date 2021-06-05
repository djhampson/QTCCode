public with sharing class orgWideEmailAddressExtension {

    public orgWideEmailAddressExtension(ApexPages.StandardController controller) {
        
    }
    
    public OrgWideEmailAddress gettoSupport() {
        /* The email address for email-to-case is buried in the Case.Settings metadata so we use the Org Wide Email Address instead 
        with the assumption that the two are the same. */
        return  [select Address from OrgWideEmailAddress order by Address LIMIT 1];
         
    }

}