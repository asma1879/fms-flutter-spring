package com.example.freelance_system.daoimpl;

import org.springframework.stereotype.Repository;

import com.example.freelance_system.dao.IUserDAO;
import com.example.freelance_system.model.User;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
@Repository
@Transactional
public class UserDAOImpl implements IUserDAO{
	
	 @PersistenceContext
	    private EntityManager entityManager;
	 
	 public UserDAOImpl(EntityManager entityManager) {
	        this.entityManager = entityManager;
	    }

	    @Override
	    public User save(User user) {
	        entityManager.persist(user);
	        return user;
	    }

	    @Override
	    public User findByEmail(String email) {
	        try {
	            return entityManager.createQuery("SELECT u FROM User u WHERE u.email = :email", User.class)
	                    .setParameter("email", email)
	                    .getSingleResult();
	        } catch (Exception e) {
	            return null; // not found
	        }
	    }
	    @Override
	    public User getUserById(long id) {
	        return entityManager.find(User.class, id);
	    }

	    @Override
	    public void updateUser(User user) {
	        entityManager.merge(user);
	        entityManager.flush(); // ensures update is applied immediately
	    }
	    
	    @Override
	    public User findById(long id) {
	        return entityManager.find(User.class, id);
	    }

	    @Override
	    public void update(User user) {
	        // No need to explicitly call merge if the entity is already managed
	        entityManager.merge(user);
	    }
}
