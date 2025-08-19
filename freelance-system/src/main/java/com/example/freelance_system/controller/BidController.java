package com.example.freelance_system.controller;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.freelance_system.dao.IBidDAO;
import com.example.freelance_system.dao.IJobDAO;
import com.example.freelance_system.dao.IUserDAO;
import com.example.freelance_system.dao.IWalletTransactionRepository;
import com.example.freelance_system.dto.BidDTO;
import com.example.freelance_system.model.Bid;
import com.example.freelance_system.model.Job;
import com.example.freelance_system.model.User;
import com.example.freelance_system.model.WalletTransaction;
import com.example.freelance_system.service.BidService;

import jakarta.transaction.Transactional;
@Transactional
@RestController
@RequestMapping("/api/auth/bids")
@CrossOrigin(origins = "*")
public class BidController {

    @Autowired
    private IBidDAO bidDAO;

    @Autowired
    private IJobDAO jobDAO;

    @Autowired
    private IUserDAO userDAO;

    @Autowired
    private BidService bidService;
    
    @Autowired
    private IWalletTransactionRepository walletTransactionRepository;


    @PostMapping("/apply")
    public Bid applyToJob(@RequestParam Long freelancerId,
                          @RequestParam Long jobId,
                          @RequestBody Bid bidRequest) {

        User freelancer = userDAO.getUserById(freelancerId);
        if (freelancer == null) {
            throw new RuntimeException("Freelancer with id " + freelancerId + " not found");
        }

        Job job = jobDAO.getJobById(jobId);
        if (job == null) {
            throw new RuntimeException("Job with id " + jobId + " not found");
        }

        Bid bid = new Bid();
        bid.setAmount(bidRequest.getAmount());
        bid.setProposalMessage(bidRequest.getProposalMessage());
        bid.setBidTime(LocalDateTime.now());
        bid.setFreelancer(freelancer);
        bid.setJob(job);

        return bidDAO.saveBid(bid);
    }

//    @GetMapping("/job/{jobId}")
//    public List<Bid> getBidsForJob(@PathVariable Long jobId) {
//        Job job = jobDAO.getJobById(jobId);
//        if (job == null) {
//            throw new RuntimeException("Job with id " + jobId + " not found");
//        }
//        return bidDAO.getBidsByJob(job);
//    }
    @GetMapping("/job/{jobId}")
    public List<BidDTO> getBidsForJob(@PathVariable Long jobId) {
        List<Bid> bids = bidDAO.getBidsByJob(jobDAO.getJobById(jobId));
        return bids.stream().map(this::mapToDTO).toList();
    }

    private BidDTO mapToDTO(Bid bid) {
        BidDTO dto = new BidDTO();
        dto.setId(bid.getId());
        dto.setAmount(bid.getAmount());
        dto.setProposalMessage(bid.getProposalMessage());
        dto.setStatus(bid.getStatus());
        dto.setDeliveryStatus(bid.getDeliveryStatus());
        dto.setDeliveryLink(bid.getDeliveryLink());
        dto.setBidTime(bid.getBidTime());
        dto.setFreelancerName(bid.getFreelancer() != null ? bid.getFreelancer().getName() : null);
        if (bid.getJob() != null) {
            dto.setJobId(bid.getJob().getId());
            dto.setJobTitle(bid.getJob().getTitle());
        }
        return dto;
    }


    @PostMapping("/{bidId}/status")
    public ResponseEntity<?> updateBidStatus(@PathVariable Long bidId, @RequestParam String status) {
        bidService.updateBidStatus(bidId, status.toUpperCase());
        return ResponseEntity.ok("Bid " + status + " successfully.");
    }

    @GetMapping("/freelancer/{freelancerId}/my-jobs")
    public ResponseEntity<List<Bid>> getAcceptedBids(@PathVariable Long freelancerId) {
        List<Bid> bids = bidDAO.getAcceptedBidsByFreelancer(freelancerId);
        return ResponseEntity.ok(bids);
    }

    @PostMapping("/{bidId}/deliver")
    public ResponseEntity<String> deliverJob(@PathVariable Long bidId,
                                             @RequestBody(required = false) Map<String, String> body) {
        String deliveryLink = (body != null && body.containsKey("deliveryLink")) ? body.get("deliveryLink") : "File/Link";
        bidDAO.updateDelivery(bidId, deliveryLink, LocalDateTime.now());
        return ResponseEntity.ok("Job delivered");
    }

   
//    @PostMapping("/{bidId}/confirm-payment")
//    public ResponseEntity<String> confirmPayment(@PathVariable Long bidId) {
//        try {
//            Bid bid = bidDAO.findById(bidId);
//            if (bid == null || !"DELIVERED".equalsIgnoreCase(bid.getDeliveryStatus())) {
//                return ResponseEntity.badRequest().body("Invalid or undelivered bid");
//            }
//
//            if (bid.isPaidToFreelancer()) {
//                return ResponseEntity.badRequest().body("Payment already released");
//            }
//
//            User systemAccount = userDAO.getUserById(9L);
//            User freelancer = bid.getFreelancer();
//            double amount = bid.getAmount();
//
//            if (systemAccount.getWalletBalance() < amount) {
//                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("System has insufficient funds");
//            }
//
//            // Calculate amounts
//            double freelancerAmount = amount * 0.90; // 90%
//            double systemCommission = amount * 0.10; // 10%
//
//            // Deduct full amount from system account (escrow)
//            systemAccount.setWalletBalance(systemAccount.getWalletBalance() - amount);
//
//            // Add 90% to freelancer
//            freelancer.setWalletBalance(freelancer.getWalletBalance() + freelancerAmount);
//
//            // System keeps 10% commission (already deducted from walletBalance)
//
//            userDAO.update(systemAccount);
//            userDAO.update(freelancer);
//            bidDAO.markAsPaid(bidId); // mark bid as paid
//
//            return ResponseEntity.ok("Payment released to freelancer with 10% commission kept by system.");
//        } catch (Exception e) {
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Payment release failed.");
//        }
//    }

    @PostMapping("/{bidId}/confirm-payment")
    public ResponseEntity<String> confirmPayment(@PathVariable Long bidId) {
    	System.out.println("confirmPayment called for bidId: " + bidId);
        try {
            Bid bid = bidDAO.findById(bidId);
            if (bid == null || !"DELIVERED".equalsIgnoreCase(bid.getDeliveryStatus())) {
                return ResponseEntity.badRequest().body("Invalid or undelivered bid");
            }

            if (bid.isPaidToFreelancer()) {
                return ResponseEntity.badRequest().body("Payment already released");
            }

            User systemAccount = userDAO.getUserById(9L);  // system account (escrow + commission holder)
            User freelancer = bid.getFreelancer();
            User client = bid.getJob().getClient();
            double amount = bid.getAmount();

            if (systemAccount.getWalletBalance() < amount) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("System has insufficient funds");
            }

            // Calculate amounts
            double freelancerAmount = amount * 0.90; // 90% to freelancer
            // double systemCommission = amount * 0.10; // optional if you want to show

            // ✅ Deduct only 90% from system account (system retains 10%)
            systemAccount.setWalletBalance(systemAccount.getWalletBalance() - freelancerAmount);

            // ✅ Credit freelancer
            freelancer.setWalletBalance(freelancer.getWalletBalance() + freelancerAmount);

            // Save updates
            userDAO.update(systemAccount);
            
            WalletTransaction txClient = new WalletTransaction();
            txClient.setUser(client);
            txClient.setAmount(-amount);
            txClient.setType("RELEASE_PAYMENT");
            txClient.setDescription("Released payment to freelancer for bid " + bidId);
            txClient.setTransactionDate(LocalDateTime.now());
            walletTransactionRepository.save(txClient);
            
            WalletTransaction txSystem = new WalletTransaction();
            txSystem.setUser(systemAccount);
            txSystem.setAmount(-freelancerAmount);
            txSystem.setType("RELEASE");
            txSystem.setDescription("System released payment to freelancer for bid " + bidId);
            txSystem.setTransactionDate(LocalDateTime.now());
            walletTransactionRepository.save(txSystem);
            walletTransactionRepository.flush();
            System.out.println("System transaction saved: " + txSystem);
            userDAO.update(freelancer);
            WalletTransaction txFreelancer = new WalletTransaction();
            txFreelancer.setUser(freelancer);
            txFreelancer.setAmount(freelancerAmount);
            txFreelancer.setType("FREELANCER_RECEIVED");
            txFreelancer.setDescription("Freelancer received payment for bid " + bidId);
            txFreelancer.setTransactionDate(LocalDateTime.now());
            walletTransactionRepository.save(txFreelancer);
            walletTransactionRepository.flush();
            System.out.println("Freelancer transaction saved: " + txFreelancer);
            bidDAO.markAsPaid(bidId); // mark bid as paid

            return ResponseEntity.ok("Payment released to freelancer. System retained 10% commission.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Payment release failed.");
        }
    }

    @GetMapping("/client/{clientId}/delivered")
    public ResponseEntity<List<Bid>> getDeliveredBidsForClient(@PathVariable Long clientId) {
        List<Bid> delivered = bidDAO.findDeliveredBidsByClientId(clientId);
        return ResponseEntity.ok(delivered);
    }
    
//    @GetMapping("/freelancer/{freelancerId}")
//    public List<Bid> getBidsByFreelancer(@PathVariable Long freelancerId) {
//        return bidDAO.getBidsByFreelancerId(freelancerId);
//    }
    @GetMapping("/freelancer/{freelancerId}")
    public List<BidDTO> getBidsByFreelancer(@PathVariable Long freelancerId) {
        List<Bid> bids = bidDAO.getBidsByFreelancerId(freelancerId);
        return bids.stream().map(bid -> {
            BidDTO dto = new BidDTO();
            dto.setId(bid.getId());
            dto.setAmount(bid.getAmount());
            dto.setProposalMessage(bid.getProposalMessage());
            dto.setStatus(bid.getStatus());
            dto.setDeliveryStatus(bid.getDeliveryStatus());
            dto.setDeliveryLink(bid.getDeliveryLink());
            dto.setBidTime(bid.getBidTime());
            dto.setFreelancerName(bid.getFreelancer().getName()); // <-- assign name
            if (bid.getJob() != null) {
                dto.setJobId(bid.getJob().getId());
                dto.setJobTitle(bid.getJob().getTitle());
            }
            return dto;
        }).toList();
    }

//    @PostMapping("/{bidId}/accept")
//    public ResponseEntity<String> acceptBidAndHoldFunds(@PathVariable Long bidId) {
//        try {
//            Bid bid = bidDAO.findById(bidId);
//            if (bid == null) return ResponseEntity.badRequest().body("Bid not found");
//
//            User client = bid.getJob().getClient();
//            User systemAccount = userDAO.getUserById(9L); // system wallet
//            double amount = bid.getAmount();
//
//            if (client.getWalletBalance() < amount) {
//                return ResponseEntity.badRequest().body("Insufficient balance");
//            }
//
//            // Transfer to system wallet
//            client.setWalletBalance(client.getWalletBalance() - amount);
//            systemAccount.setWalletBalance(systemAccount.getWalletBalance() + amount);
//
//            userDAO.update(client);
//            userDAO.update(systemAccount);
//            bidService.updateBidStatus(bidId, "ACCEPTED");
//
//            return ResponseEntity.ok("Bid accepted and amount held in escrow.");
//        } catch (Exception e) {
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error accepting bid.");
//        }
//    }
    
    @PostMapping("/{bidId}/accept")
    public ResponseEntity<String> acceptBidAndHoldFunds(@PathVariable Long bidId) {
        try {
            Bid bid = bidDAO.findById(bidId);
            if (bid == null) return ResponseEntity.badRequest().body("Bid not found");

            User client = bid.getJob().getClient();
            User systemAccount = userDAO.getUserById(9L); // system wallet
            double amount = bid.getAmount();

            if (client.getWalletBalance() < amount) {
                return ResponseEntity.badRequest().body("Insufficient balance");
            }

            // 🔹 Transfer to system wallet
            client.setWalletBalance(client.getWalletBalance() - amount);
            systemAccount.setWalletBalance(systemAccount.getWalletBalance() + amount);

            userDAO.update(client);
            userDAO.update(systemAccount);
            bidService.updateBidStatus(bidId, "ACCEPTED");

            // 🔹 Save wallet transaction for client (funds held)
            WalletTransaction txClient = new WalletTransaction();
            txClient.setUser(client);
            txClient.setAmount(-amount);
            txClient.setType("HOLD_FUNDS");
            txClient.setDescription("Funds held in escrow for bid " + bidId);
            txClient.setTransactionDate(LocalDateTime.now());
            walletTransactionRepository.save(txClient);

            // 🔹 Save wallet transaction for system (escrow received)
            WalletTransaction txSystem = new WalletTransaction();
            txSystem.setUser(systemAccount);
            txSystem.setAmount(amount);
            txSystem.setType("ESCROW_RECEIVED");
            txSystem.setDescription("System escrow received funds for bid " + bidId);
            txSystem.setTransactionDate(LocalDateTime.now());
            walletTransactionRepository.save(txSystem);

            walletTransactionRepository.flush();

            return ResponseEntity.ok("Bid accepted and amount held in escrow.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error accepting bid.");
        }
    }

    @GetMapping("/count-delivered")
    public long getDeliveredCount() {
        return bidDAO.countDelivered();
    }
    
    @GetMapping("/{freelancerId}/overview")
    public ResponseEntity<Map<String, Long>> getBidOverview(@PathVariable Long freelancerId) {
        Map<String, Long> counts = bidDAO.getBidOverviewCounts(freelancerId);
        return ResponseEntity.ok(counts);
    }
    
    
}
