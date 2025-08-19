package com.example.freelance_system.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "bids")
public class Bid {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private double amount;
    
    @Column
    private String deliveryLink;

    @Column
    private LocalDateTime deliveryTime;

   
    @Column(columnDefinition = "TEXT")
    private String proposalMessage;

    private LocalDateTime bidTime;

    @ManyToOne
    @JoinColumn(name = "freelancer_id")
    private User freelancer;

    @ManyToOne
    @JoinColumn(name = "job_id")
    private Job job; 
    @Column(nullable = false)
    private String status = "PENDING";
    @Column(nullable = false)
    private String deliveryStatus = "NOT_DELIVERED";
    @Column(name = "is_paid_to_freelancer", nullable = false)
    private boolean isPaidToFreelancer = false;

    public String getDeliveryLink() {
		return deliveryLink;
	}

	public void setDeliveryLink(String deliveryLink) {
		this.deliveryLink = deliveryLink;
	}

	public LocalDateTime getDeliveryTime() {
		return deliveryTime;
	}

	public void setDeliveryTime(LocalDateTime deliveryTime) {
		this.deliveryTime = deliveryTime;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public double getAmount() {
		return amount;
	}

	public void setAmount(double amount) {
		this.amount = amount;
	}

	public String getProposalMessage() {
		return proposalMessage;
	}

	public void setProposalMessage(String proposalMessage) {
		this.proposalMessage = proposalMessage;
	}

	public LocalDateTime getBidTime() {
		return bidTime;
	}

	public void setBidTime(LocalDateTime bidTime) {
		this.bidTime = bidTime;
	}

	public User getFreelancer() {
		return freelancer;
	}

	public void setFreelancer(User freelancer) {
		this.freelancer = freelancer;
	}

	public Job getJob() {
		return job;
	}

	public void setJob(Job job) {
		this.job = job;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getDeliveryStatus() {
		return deliveryStatus;
	}

	public void setDeliveryStatus(String deliveryStatus) {
		this.deliveryStatus = deliveryStatus;
	}

	public boolean isPaidToFreelancer() {
		return isPaidToFreelancer;
	}

	public void setPaidToFreelancer(boolean isPaidToFreelancer) {
		this.isPaidToFreelancer = isPaidToFreelancer;
	}
    
    

    
}
