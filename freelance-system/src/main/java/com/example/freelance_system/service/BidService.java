package com.example.freelance_system.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.freelance_system.dao.IBidDAO;
import com.example.freelance_system.model.Bid;
import com.example.freelance_system.model.Job;

@Service
public class BidService {

    @Autowired
    private IBidDAO bidDAO;

    public Bid saveBid(Bid bid) {
        return bidDAO.saveBid(bid);
    }

    public List<Bid> getBidsByJob(Job job) {
        return bidDAO.getBidsByJob(job);
    }
    public void updateBidStatus(Long bidId, String status) {
        bidDAO.updateBidStatus(bidId, status);
    }

}
