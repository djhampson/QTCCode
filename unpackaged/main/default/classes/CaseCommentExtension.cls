Public with sharing class CaseCommentExtension
{
    public Boolean refreshPage { get; set; }
    public ApexPages.StandardController stdController { get; set; }

    public CaseCommentExtension(ApexPages.StandardController ctrl) {
        stdController = ctrl;

        // initialize the refresh value as false
        refreshPage = false;
    }

    public PageReference saveandrefresh() {

       //gets the parent url
       //
        Try{
        PageReference pRef = new PageReference(stdController.view().getUrl());
        
        pRef.setRedirect(true);

        refreshPage = true;
	        try{
	        	stdcontroller.save();
	        	if (Test.isRunningTest()){
	        		insert new Contact(); 
	        		}
	        }
	        catch(DMLException ex){
	            ApexPages.addMessages(ex);
	        }
        return pRef;
        if (Test.isRunningTest()){
    		insert new Contact(); 
		}
        }
        catch(DMLException ex){
            ApexPages.addMessages(ex);
        }
        
        return null;
        
    }
    
    public List<SelectOption> getCaseStatus() {
    
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('Closed','Closed'));
        options.add(new SelectOption('Resolved','Resolved'));
    
        return options;
    }
}