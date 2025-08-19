package com.example.freelance_system.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.freelance_system.dao.IUserDAO;
import com.example.freelance_system.dao.IWalletTransactionRepository;
import com.example.freelance_system.model.User;
import com.example.freelance_system.model.WalletTransaction;

import jakarta.transaction.Transactional;
@Transactional
@RestController
@RequestMapping("/api/auth/wallet")
@CrossOrigin(origins = "*")
public class WalletReportController {

    @Autowired
    private IUserDAO userDAO;

    @Autowired
    private IWalletTransactionRepository walletTransactionRepository;

    @GetMapping("/{userId}/report")
    public ResponseEntity<WalletReportResponse> getWalletReport(@PathVariable Long userId) {
        User user = userDAO.getUserById(userId);
        if (user == null) return ResponseEntity.notFound().build();

        List<WalletTransaction> transactions = walletTransactionRepository.findByUserOrderByTransactionDateDesc(user);
        double walletBalance = user.getWalletBalance();

        WalletReportResponse response = new WalletReportResponse(walletBalance, transactions);
        return ResponseEntity.ok(response);
    }

    public static class WalletReportResponse {
        private double walletBalance;
        private List<WalletTransaction> transactions;

        public WalletReportResponse(double walletBalance, List<WalletTransaction> transactions) {
            this.walletBalance = walletBalance;
            this.transactions = transactions;
        }

        public double getWalletBalance() { return walletBalance; }
        public List<WalletTransaction> getTransactions() { return transactions; }
    }
}

