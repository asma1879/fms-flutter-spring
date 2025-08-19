package com.example.freelance_system.dao;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import com.example.freelance_system.model.Bid;
import com.example.freelance_system.model.Job;

public interface IBidDAO {
    Bid saveBid(Bid bid);
    List<Bid> getBidsByJob(Job job);
    void updateBidStatus(Long bidId, String status);
    List<Bid> getAcceptedBidsByFreelancer(Long freelancerId);
    void markBidAsDelivered(Long bidId);
    Bid findById(long id);
    void updateDelivery(long bidId, String deliveryLink, LocalDateTime deliveryTime);
    //void markAsPaid(long bidId);
    List<Bid> findDeliveredBidsByClientId(long clientId);
    void markAsPaidAndTransferFunds(long bidId);
    void markAsPaid(Long bidId);
    long countDelivered();
    List<Bid> getBidsByFreelancerId(Long freelancerId);
    Map<String, Long> getBidOverviewCounts(Long freelancerId);
    List<Object[]> getBidCountByStatus();
}
