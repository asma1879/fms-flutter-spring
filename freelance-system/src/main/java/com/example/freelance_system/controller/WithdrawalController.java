package com.example.freelance_system.controller;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.freelance_system.dao.IUserDAO;
import com.example.freelance_system.dao.IWalletTransactionRepository;
import com.example.freelance_system.dao.IWithdrawalDAO;
import com.example.freelance_system.model.User;
import com.example.freelance_system.model.WalletTransaction;
import com.example.freelance_system.model.WithdrawalRequest;

@RestController
@RequestMapping("/api/auth/withdraw")
@CrossOrigin("*")
public class WithdrawalController {

    @Autowired
    private IWithdrawalDAO withdrawalDAO;

    @Autowired
    private IUserDAO userDAO;
    @Autowired
    private IWalletTransactionRepository walletTransactionRepository;

    
    @PostMapping("/freelancer/{id}")
    public ResponseEntity<String> requestWithdrawal(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body) {

        double amount = Double.parseDouble(body.get("amount").toString());
        String method = (String) body.get("method");
        String accountInfo = (String) body.get("accountInfo");

        User freelancer = userDAO.getUserById(id);

        if (freelancer == null) return ResponseEntity.notFound().build();
        if (freelancer.getWalletBalance() < amount) {
            return ResponseEntity.badRequest().body("Insufficient wallet balance");
        }

        // 💰 Deduct immediately
        freelancer.setWalletBalance(freelancer.getWalletBalance() - amount);
        userDAO.update(freelancer);

        WithdrawalRequest request = new WithdrawalRequest();
        request.setFreelancerId(id);
        request.setMethod(method);
        request.setAccountInfo(accountInfo);
        request.setAmount(amount);
        request.setStatus("COMPLETED"); // ✅ Mark immediately completed
        WalletTransaction tx = new WalletTransaction();
        tx.setUser(freelancer);
        tx.setAmount(-amount); // negative since withdrawal
        tx.setType("WITHDRAWAL");
        tx.setDescription("Freelancer withdrew funds");
        tx.setTransactionDate(LocalDateTime.now());
        walletTransactionRepository.save(tx);

        withdrawalDAO.saveRequest(request);

        return ResponseEntity.ok("Withdrawal processed successfully.");
    }

    @GetMapping("/freelancer/{id}")
    public List<WithdrawalRequest> getHistory(@PathVariable Long id) {
        return withdrawalDAO.getByFreelancerId(id);
    }
    
}
