package com.example.freelance_system.daoimpl;

import org.springframework.stereotype.Repository;

import com.example.freelance_system.dao.IFreelancerDAO;
import com.example.freelance_system.model.Freelancer;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;

@Repository
@Transactional
public class FreelancerDAOImpl implements IFreelancerDAO{

    @PersistenceContext
    private EntityManager entityManager;

    @Override
    public Freelancer getFreelancerById(int id) {
        return entityManager.find(Freelancer.class, id);
    }

    @Override
    public void updateFreelancer(Freelancer freelancer) {
        entityManager.merge(freelancer);
    }

}
