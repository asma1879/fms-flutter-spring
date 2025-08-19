package com.example.freelance_system.daoimpl;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.example.freelance_system.dao.IWithdrawalDAO;
import com.example.freelance_system.model.WithdrawalRequest;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;

@Repository
@Transactional
public class WithdrawalDAOImpl implements IWithdrawalDAO {

    @PersistenceContext
    private EntityManager em;

    @Override
    public void saveRequest(WithdrawalRequest request) {
        em.persist(request);
    }

    @Override
    public List<WithdrawalRequest> getByFreelancerId(Long id) {
        String query = "FROM WithdrawalRequest w WHERE w.freelancerId = :id ORDER BY w.requestDate DESC";
        return em.createQuery(query, WithdrawalRequest.class)
                 .setParameter("id", id)
                 .getResultList();
    }
}

