public class OpportunityDAO {
    public static List<Opportunity> getByIds(Set<Id> oppIds) {
        if (oppIds == null || oppIds.isEmpty()) return new List<Opportunity>();
        return [SELECT Id, StageName FROM Opportunity WHERE Id IN :oppIds];
    }
}
