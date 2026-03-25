public class PricebookEntryDAO {
    public static List<PricebookEntry> getByIds(Set<Id> pbeIds) {
        if (pbeIds == null || pbeIds.isEmpty()) return new List<PricebookEntry>();
        return [SELECT Id, Product2Id FROM PricebookEntry WHERE Id IN :pbeIds];
    }
}
