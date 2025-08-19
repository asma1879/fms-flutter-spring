package com.example.freelance_system.controller;

import java.time.LocalDateTime;
import java.util.Date;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.freelance_system.dao.IClientDAO;
import com.example.freelance_system.dao.IFundDAO;
import com.example.freelance_system.dao.IUserDAO;
import com.example.freelance_system.dao.IWalletTransactionRepository;
import com.example.freelance_system.model.Client;
import com.example.freelance_system.model.Fund;
import com.example.freelance_system.model.User;
import com.example.freelance_system.model.WalletTransaction;

@RestController
@RequestMapping("/api/auth/funds")
@CrossOrigin("*")
public class FundController {

    @Autowired
    private IFundDAO fundDAO;

    @Autowired
    private IUserDAO userDAO;
    
    @Autowired
    private IWalletTransactionRepository walletTransactionRepository;


    @PostMapping("/add")
    public ResponseEntity<String> addFund(@RequestBody Fund fund) {
        try {
            fund.setDate(new Date());
            fund.setStatus("Success");
            fundDAO.saveFund(fund);

            User user = userDAO.getUserById(fund.getClientId());
            if (user != null && "CLIENT".equalsIgnoreCase(user.getRole())) {
                double newBalance = user.getWalletBalance() + fund.getAmount();
                user.setWalletBalance(newBalance);
                userDAO.updateUser(user);
                WalletTransaction tx = new WalletTransaction();
                tx.setUser(user);
                tx.setAmount(fund.getAmount());
                tx.setType("DEPOSIT");
                tx.setDescription("Client added funds");
                tx.setTransactionDate(LocalDateTime.now());
                walletTransactionRepository.save(tx);
            }

            return ResponseEntity.ok("Fund added successfully and wallet updated");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error: " + e.getMessage());
        }
    }
}
