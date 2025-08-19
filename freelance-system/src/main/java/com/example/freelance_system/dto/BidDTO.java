package com.example.freelance_system.dto;

import java.time.LocalDateTime;

public class BidDTO {
    private Long id;
    private double amount;
    private String proposalMessage;
    private String status;
    private String deliveryStatus;
    private String deliveryLink;
    private LocalDateTime bidTime;
    private String freelancerName; // <-- new
    private Long jobId;
    private String jobTitle;

    // getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }
    public String getProposalMessage() { return proposalMessage; }
    public void setProposalMessage(String proposalMessage) { this.proposalMessage = proposalMessage; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getDeliveryStatus() { return deliveryStatus; }
    public void setDeliveryStatus(String deliveryStatus) { this.deliveryStatus = deliveryStatus; }
    public String getDeliveryLink() { return deliveryLink; }
    public void setDeliveryLink(String deliveryLink) { this.deliveryLink = deliveryLink; }
    public LocalDateTime getBidTime() { return bidTime; }
    public void setBidTime(LocalDateTime bidTime) { this.bidTime = bidTime; }
    public String getFreelancerName() { return freelancerName; }
    public void setFreelancerName(String freelancerName) { this.freelancerName = freelancerName; }
    public Long getJobId() { return jobId; }
    public void setJobId(Long jobId) { this.jobId = jobId; }
    public String getJobTitle() { return jobTitle; }
    public void setJobTitle(String jobTitle) { this.jobTitle = jobTitle; }
}
