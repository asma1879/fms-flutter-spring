package com.example.freelance_system.daoimpl;

import com.example.freelance_system.dao.IFreelancerProfileDAO;
import com.example.freelance_system.model.FreelancerProfile;

import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Repository;

@Repository
@Transactional
public class FreelancerProfileDAOImpl implements IFreelancerProfileDAO{
	@PersistenceContext
    private EntityManager entityManager;

    @Override
    public FreelancerProfile saveOrUpdate(FreelancerProfile profile) {
        return entityManager.merge(profile);
    }

//    @Override
//    public FreelancerProfile getByUserId(Long userId) {
//        return entityManager.createQuery("FROM FreelancerProfile WHERE userId = :userId", FreelancerProfile.class)
//                .setParameter("userId", userId)
//                .getSingleResult();
//    }
    @Override
    public FreelancerProfile getByUserId(Long userId) {
        try {
            return entityManager.createQuery("FROM FreelancerProfile WHERE userId = :userId", FreelancerProfile.class)
                     .setParameter("userId", userId)
                     .getSingleResult();
        } catch (NoResultException e) {
            return null; // 🚨 Profile not found — return null
        }
    }


}
