@isTest(SeeAllData=True)
public class TestInsertIdea {
   
    public static testmethod void testInsertIdea() {
     
        // get the customer community id
        Id commID = [Select Id from Community where name like 'Customer%'].Id;
        system.debug(commId);
        
        // get the current user id
        User Usr = new User();
        Usr = [SELECT Id FROM User WHERE Id = : UserInfo.getUserId()];
        system.debug(Usr.id);
        String bodyToUse = 
        '<p><img src="https://technologyone--c.documentforce.com/servlet/servlet.ImageServer?id=0155K0000008ufjQAA&amp;oid=00DG0000000jBjuMAE"></img></p> <p> </p> <p>The reason for this negative balance is that they have booked leave off early next year, however, they will have accrued a significant amount of leave by that holiday which covers the leave they have requested, so, in actual fact, as at today, they do have leave available that they can use as the future leave will make use of their future accruals.</p>';
        /* list<Idea> exIdea = [select id, body from Idea order by createddate desc];
        for (Idea iIdea :exIdea){
            if (iIdea.Body.Contains('<img src')){
                bodyToUse = iIdea.Body;
                break;
            }
        } */
        
        Idea i = new Idea();
        i.Title = 'Testing';
        i.Owner__c = Usr.id;
        i.Functional_Area__c = 'Test';
        i.CommunityId = commId;
        i.Categories = '~ Cloud';
        i.Body = bodyToUse;
        insert i;
        System.assertEquals('Testing', i.title);

        /* try{

            for (Idea iIdea :exIdea){
                if (iIdea.Body.Contains('/download/')){
                    bodyToUse = iIdea.Body;
                    break;
                }
            }
        }
        catch(Exception e){
                
            } */
        bodyToUse = '<p>Difficult to find replies to comments in chatter feed.<br>You have to go in and expand each ' + 
                    'comment to try and find the reply.<br>Suggest a different layout &quot;Chronological only&quot; rather' + 
                    ' than &quot;Chronological then Nested&quot;.</p><p><img src="https://confluence.t1cloud.com/download/attachments/6293983/image2016-3-4%204%3A51%3A53.png?version=1&amp;modificationDate=1457031155000&amp;api=v2"></img></p>';
        Idea i2 = new Idea();
        i2.Title = 'Testing 2';
        i2.Owner__c = Usr.id;
        i2.Functional_Area__c = 'Test';
        i2.CommunityId = commId;
        i2.Categories = '~ Cloud';
        i2.Body = bodyToUse;
        insert i2;
        System.assertEquals('Testing 2', i2.title);



       /*  try{
            for (Idea iIdea :exIdea){
                if (iIdea.Body.Contains('?')){
                    bodyToUse = iIdea.Body;
                    break;
                }
            }
        }
        catch(Exception e){
                
            } */

        Idea i3 = new Idea();
        i3.Title = 'Testing 3';
        i3.Owner__c = Usr.id;
        i3.Functional_Area__c = 'Test';
        i3.CommunityId = commId;
        i3.Categories = '~ Cloud';
        i3.Body = 'Test';
        insert i3;
        System.assertEquals('Testing 3', i3.title);


        // add subscriber
        Usr = [SELECT Id FROM User WHERE name = 'Allan Benson'];
        acideas__brIdeaSubscription__c is = new acideas__brIdeaSubscription__c();
        is.acideas__Idea__c = i3.Id;
        is.acideas__User__c = Usr.Id;
        insert is;
        // change status
       /*  i3.Status = 'Under Consideration';
        update i3;  */
 
		//now insert a comment
        IdeaComment ic = new IdeaComment();
        ic.IdeaId = i3.Id;
        ic.CommentBody = 'bodyToUse';
        insert ic;   

        //insert internal idea          
        commID = [Select Id from Community where name like 'Internal%'].Id;
        i = new Idea();
        i.Title = 'Testing Internal';
        i.Owner__c = Usr.id;
        i.Functional_Area__c = 'Test';
        i.CommunityId = commId;
        i.Categories = '~ Cloud';
        i.Body = 'Testing Internal';
        insert i;
        System.assertEquals('Testing Internal', i.title);
    }
   
}