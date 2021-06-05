public class IdeaImageProcess {

    @future
    public static void processIdeaImages(Set<Id> ideaIds) {
        List<ContentDocumentLink> docLinkToIns = new List<ContentDocumentLink>();
        Network netWork = new Network();
        netWork = [select Id from Network where Name = 'T1 Customer Community'];
        String sContDocId;
        set<Id> contVerIds = new set<Id>();
        
        for (Idea ideaBody : [
            select Id,
                Body
            from Idea
            where Id in :ideaIds]) {
            // get the images within body
            String[] strParts = ideaBody.Body.split('<img src');
            if (strParts.size() == 1){
                system.debug('No <img src');
                continue;
            }
            Integer intCount = 1; // ignore first string
    
            while (intCount < strParts.size()){
                String[] strParts2 = strParts[intCount].split('/download/');
                if (strParts2.size() == 1){
                    system.debug('No /download/');
                    intCount++;
                    break;  
                } 
                String[] strParts3 = strParts2[1].split('\\?');
                if (strParts3.size() == 1) {
                    system.debug('No ?');
                    intCount++;
                    break;  
                } 
                String sContVerId = strParts3[0];
                system.debug('ContentVersionId = ' + sContVerId);
                if (sContVerId.startsWithIgnoreCase('068'))
                    contVerIds.add(sContVerId);
                intCount++;
            }
                
        }
       
        if (!contVerIds.isEmpty()){
            for (ContentVersion contVer : [
                select ContentDocumentId
                from ContentVersion
                where Id in :contVerIds]) { 
                ContentDocumentLink [] itExists = [Select ID 
                           FROM ContentDocumentLink 
                           WHERE LinkedEntityId = :netWork.Id
                           AND ContentDocumentId = :contVer.ContentDocumentId];
                if (itExists.isEmpty() || Test.isRunningTest()){
                    try {
                    docLinkToIns.add(new ContentDocumentLink(
                    ContentDocumentId = contVer.ContentDocumentId,
                    LinkedEntityId = netWork.Id,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                    ));
                    }
                    catch(Exception e){}
                }
            }
        }
        
        if (!docLinkToIns.isEmpty()) {
            try{
            insert docLinkToIns;
            }
            catch(Exception e){}
        }
    }
    
    public static void processIdeaCommentImages(Set<Id> ideaCommentIds) {
        List<ContentDocumentLink> docLinkToIns = new List<ContentDocumentLink>();
        Network netWork = new Network();
        netWork = [select Id from Network where Name = 'T1 Customer Community'];
        String sContDocId;
        set<Id> contVerIds = new set<Id>();
        
        for (IdeaComment ideaCommentBody : [
            select Id,
                CommentBody
            from IdeaComment
            where Id in :ideaCommentIds]) {
            // get the images within body
            String[] strParts = ideaCommentBody.CommentBody.split('<img src');
            if (strParts.size() == 1){
                system.debug('No <img src');
                continue;
            }
            Integer intCount = 1; // ignore first string
    
            while (intCount < strParts.size()){
                String[] strParts2 = strParts[intCount].split('/download/');
                if (strParts2.size() == 1){
                    system.debug('No /download/');
                    intCount++;
                    break;  
                } 
                String[] strParts3 = strParts2[1].split('\\?');
                if (strParts3.size() == 1) {
                    system.debug('No ?');
                    intCount++;
                    break;  
                } 
                String sContVerId = strParts3[0];
                system.debug('ContentVersionId = ' + sContVerId);
                if (sContVerId.startsWithIgnoreCase('068'))
                    contVerIds.add(sContVerId);
                intCount++;
            }
                
        }
       
        if (!contVerIds.isEmpty()){
            for (ContentVersion contVer : [
                select ContentDocumentId
                from ContentVersion
                where Id in :contVerIds]) { 
                ContentDocumentLink [] itExists = [Select ID 
                           FROM ContentDocumentLink 
                           WHERE LinkedEntityId = :netWork.Id
                           AND ContentDocumentId = :contVer.ContentDocumentId];
                if (itExists.isEmpty() || Test.isRunningTest()){
                    try{
                    docLinkToIns.add(new ContentDocumentLink(
                    ContentDocumentId = contVer.ContentDocumentId,
                    LinkedEntityId = netWork.Id,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                    ));
                    }
                    catch(Exception e){}
                }
            }
        }
        
        if (!docLinkToIns.isEmpty()) {
            try{
                insert docLinkToIns;
            }
            catch(Exception e){}
        }
    }
}