package com.example.freelance_system.dao;

import java.util.List;

import com.example.freelance_system.model.WithdrawalRequest;

public interface IWithdrawalDAO {
    void saveRequest(WithdrawalRequest request);
    List<WithdrawalRequest> getByFreelancerId(Long id);
}
