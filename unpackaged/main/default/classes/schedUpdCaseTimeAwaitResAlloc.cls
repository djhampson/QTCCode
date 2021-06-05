global class schedUpdCaseTimeAwaitResAlloc implements Schedulable {
   global void execute(SchedulableContext sc) {
      UpdCaseTimeAwaitResAlloc c = new UpdCaseTimeAwaitResAlloc();
      database.executebatch(c);
   }
}