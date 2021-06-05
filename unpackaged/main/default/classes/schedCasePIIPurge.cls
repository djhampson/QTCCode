global class schedCasePIIPurge implements Schedulable {
    global void execute(SchedulableContext sc) {
       casePIIPurge c = new casePIIPurge();
       database.executebatch(c);
    }
 }