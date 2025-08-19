package com.example.freelance_system.daoimpl;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.example.freelance_system.dao.IFundDAO;
import com.example.freelance_system.model.Fund;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;

@Repository
@Transactional
public class FundDAOImpl implements IFundDAO {

    @PersistenceContext
    private EntityManager entityManager;

    @Override
    public void saveFund(Fund fund) {
        entityManager.persist(fund);
    }

    @Override
    public List<Fund> getFundsByClientId(int clientId) {
        return entityManager
            .createQuery("FROM Fund WHERE clientId = :clientId", Fund.class)
            .setParameter("clientId", clientId)
            .getResultList();
    }
}
