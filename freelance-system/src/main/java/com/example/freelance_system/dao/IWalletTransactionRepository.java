package com.example.freelance_system.dao;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.freelance_system.model.User;
import com.example.freelance_system.model.WalletTransaction;

public interface IWalletTransactionRepository extends JpaRepository<WalletTransaction, Long> {
    List<WalletTransaction> findByUserOrderByTransactionDateDesc(User user);
}

