package com.example.freelance_system.daoimpl;

import java.time.LocalDateTime;
import java.util.List;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.Query;
import jakarta.persistence.TypedQuery;

import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.example.freelance_system.dao.IBidDAO;
import com.example.freelance_system.model.Bid;
import com.example.freelance_system.model.Job;
import com.example.freelance_system.model.User;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
@Transactional
public class BidDAOImpl implements IBidDAO {

    @PersistenceContext
    private EntityManager entityManager;

    @Override
    public Bid saveBid(Bid bid) {
        entityManager.persist(bid);  // use persist for new, merge for update if needed
        return bid;
    }

    @Override
    public List<Bid> getBidsByJob(Job job) {
        String jpql = "SELECT b FROM Bid b WHERE b.job = :job";
        TypedQuery<Bid> query = entityManager.createQuery(jpql, Bid.class);
        query.setParameter("job", job);
        return query.getResultList();
    }
    @Override
    public void updateBidStatus(Long bidId, String status) {
        Bid bid = entityManager.find(Bid.class, bidId);
        if (bid != null) {
            bid.setStatus(status);
            entityManager.merge(bid);
        }
    }
    
    @Override
    public List<Bid> getAcceptedBidsByFreelancer(Long freelancerId) {
        String jpql = "SELECT b FROM Bid b WHERE b.freelancer.id = :freelancerId AND b.status = 'ACCEPTED'";
        TypedQuery<Bid> query = entityManager.createQuery(jpql, Bid.class);
        query.setParameter("freelancerId", freelancerId);
        return query.getResultList();
    }
    
    @Override
    public void markBidAsDelivered(Long bidId) {
        Bid bid = entityManager.find(Bid.class, bidId);
        if (bid != null && "ACCEPTED".equals(bid.getStatus())) {
            bid.setDeliveryStatus("DELIVERED"); // Make sure this field exists in Bid.java
            entityManager.merge(bid);
        }
    }

    @Override
    public Bid findById(long id) {
        return entityManager.find(Bid.class, id);
    }

    @Override
    public void updateDelivery(long bidId, String deliveryLink, LocalDateTime deliveryTime) {
        Bid bid = entityManager.find(Bid.class, bidId);
        if (bid != null) {
            bid.setDeliveryLink(deliveryLink);
            bid.setDeliveryTime(deliveryTime);
            bid.setDeliveryStatus("DELIVERED");
            bid.setStatus("DELIVERED");
            // No need to call entityManager.merge() if the entity is managed (which it is)
        }
    }
        
//        @Override
//        public void markAsPaid(long bidId) {
//            Bid bid = entityManager.find(Bid.class, bidId);
//            if (bid != null) {
//                bid.setStatus("PAID");
//            }
//        }

        @Override
        public List<Bid> findDeliveredBidsByClientId(long clientId) {
            String jpql = "SELECT b FROM Bid b WHERE b.deliveryStatus = 'DELIVERED' AND b.job.client.id = :clientId";
            return entityManager.createQuery(jpql, Bid.class)
                    .setParameter("clientId", clientId)
                    .getResultList();
        
    }
        @Override
        public void markAsPaidAndTransferFunds(long bidId) {
            Bid bid = entityManager.find(Bid.class, bidId);

            if (bid == null || !"DELIVERED".equals(bid.getDeliveryStatus()) || "PAID".equals(bid.getStatus())) {
                throw new IllegalStateException("Invalid bid payment attempt.");
            }

            User freelancer = bid.getFreelancer();
            User client = bid.getJob().getClient();

            double amount = bid.getAmount();

            if (client.getWalletBalance() < amount) {
                throw new IllegalStateException("Insufficient wallet balance.");
            }

            // Deduct from client
            client.setWalletBalance(client.getWalletBalance() - amount);

            // Add to freelancer
            freelancer.setWalletBalance(freelancer.getWalletBalance() + amount);

            // Update bid status
            bid.setStatus("PAID");

            // Save updates
            entityManager.merge(client);
            entityManager.merge(freelancer);
            entityManager.merge(bid);
        }
        
        @Override
        public List<Bid> getBidsByFreelancerId(Long freelancerId) {
            String query = "SELECT b FROM Bid b WHERE b.freelancer.id = :freelancerId";
            return entityManager.createQuery(query, Bid.class)
                                .setParameter("freelancerId", freelancerId)
                                .getResultList();
        }
        
      
        @Override
        public void markAsPaid(Long bidId) {
            Bid bid = entityManager.find(Bid.class, bidId);
            if (bid != null) {
                bid.setPaidToFreelancer(true); // this must exist
                bid.setStatus("PAID"); // optional if needed in UI
                entityManager.merge(bid);
            }
        }
        
        @Override
        public long countDelivered() {
            String jpql = "SELECT COUNT(b) FROM Bid b WHERE b.deliveryStatus = 'DELIVERED'";
            return (long) entityManager.createQuery(jpql).getSingleResult();
        }
        
        @Override
        public Map<String, Long> getBidOverviewCounts(Long freelancerId) {
            String jpql = "SELECT " +
                    "SUM(CASE WHEN b.status = 'PENDING' THEN 1 ELSE 0 END) as pendingCount, " +
                    "SUM(CASE WHEN b.status = 'ACCEPTED' AND b.deliveryStatus <> 'DELIVERED' THEN 1 ELSE 0 END) as inProgressCount, " +
                    "SUM(CASE WHEN b.deliveryStatus = 'DELIVERED' AND b.isPaidToFreelancer = false THEN 1 ELSE 0 END) as deliveredNotPaidCount, " +
                    "SUM(CASE WHEN b.deliveryStatus = 'DELIVERED' AND b.isPaidToFreelancer = true THEN 1 ELSE 0 END) as completedCount, " +
                    "SUM(CASE WHEN b.status = 'REJECTED' THEN 1 ELSE 0 END) as rejectedCount, " +
                    "COUNT(b) as totalProposals " +
                    "FROM Bid b WHERE b.freelancer.id = :freelancerId";

            Object[] result = (Object[]) entityManager.createQuery(jpql)
                .setParameter("freelancerId", freelancerId)
                .getSingleResult();
            Map<String, Long> counts = new HashMap<>();
            counts.put("pendingCount", ((Number) result[0]).longValue());
            counts.put("inProgressCount", ((Number) result[1]).longValue());
            counts.put("deliveredNotPaidCount", ((Number) result[2]).longValue());
            counts.put("completedCount", ((Number) result[3]).longValue());
            counts.put("rejectedCount", ((Number) result[4]).longValue());
            counts.put("totalProposals", ((Number) result[5]).longValue());

            return counts;
        }
        
        @Override
        public List<Object[]> getBidCountByStatus() {
            String sql = "SELECT b.status, COUNT(b.id) FROM Bid b GROUP BY b.status";
            return entityManager.createQuery(sql, Object[].class).getResultList();
        }

}
