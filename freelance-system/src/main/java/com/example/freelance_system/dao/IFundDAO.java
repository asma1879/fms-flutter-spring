package com.example.freelance_system.dao;

import java.util.List;

import com.example.freelance_system.model.Fund;

public interface IFundDAO {
    void saveFund(Fund fund);
    List<Fund> getFundsByClientId(int clientId);
}

