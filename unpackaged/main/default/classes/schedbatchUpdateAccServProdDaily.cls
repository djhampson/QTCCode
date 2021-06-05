global class schedbatchUpdateAccServProdDaily implements Schedulable {
    global void execute(SchedulableContext sc) {
        batchUpdateAccServProdDaily c = new batchUpdateAccServProdDaily();
        database.executebatch(c);
    }
}