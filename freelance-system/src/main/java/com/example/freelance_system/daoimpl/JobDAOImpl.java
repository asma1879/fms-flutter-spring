package com.example.freelance_system.daoimpl;

import java.util.List;

import org.springframework.stereotype.Repository;

import com.example.freelance_system.dao.IJobDAO;
import com.example.freelance_system.model.Job;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;

@Repository
@Transactional
public class JobDAOImpl implements IJobDAO {

    @PersistenceContext
    private EntityManager entityManager;

    @Override
    public void saveJob(Job job) {
        entityManager.persist(job);
    }

    @Override
    public List<Job> getJobsByClientId(Long clientId) {
        return entityManager.createQuery(
            "SELECT j FROM Job j WHERE j.client.id = :clientId", Job.class)
            .setParameter("clientId", clientId)
            .getResultList();
    }

    @Override
    public List<Job> getAllJobs() {
        return entityManager.createQuery("FROM Job", Job.class).getResultList();
    }

    @Override
    public Job getJobById(Long jobId) {
        return entityManager.find(Job.class, jobId);
    }
    @Override
    public List<Object[]> getJobCountPerMonth() {
        String jpql = "SELECT FUNCTION('MONTH', FUNCTION('STR_TO_DATE', j.deadline, '%Y-%m-%d')), COUNT(j.id) "
                    + "FROM Job j GROUP BY FUNCTION('MONTH', FUNCTION('STR_TO_DATE', j.deadline, '%Y-%m-%d'))";
        return entityManager.createQuery(jpql, Object[].class).getResultList();
    }

}

