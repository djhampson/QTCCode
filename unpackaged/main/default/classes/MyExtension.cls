public class MyExtension {
    private final Case ca;
    public Boolean refreshPage { get; set; }
    
    ApexPages.StandardController sController { get; set; } 
    
    public MyExtension(ApexPages.StandardController controller) {
        sController = controller;    
        this.ca = (Case)controller.getRecord();
        refreshPage = false;
    }
    
    
    public String getTitle() {
        return 'Case: ' + ca.id;
    }
    
    
    public PageReference save()
    {
        PageReference pRef = new PageReference(sController.view().getUrl());
        
        pRef.setRedirect(true);

        refreshPage = true;
        
        sController.save();
              
        return pRef;    
    }
}