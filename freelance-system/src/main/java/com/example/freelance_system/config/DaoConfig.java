package com.example.freelance_system.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.example.freelance_system.dao.IUserDAO;
import com.example.freelance_system.daoimpl.UserDAOImpl;

import jakarta.persistence.EntityManager;

@Configuration
public class DaoConfig {
	@Bean
    public IUserDAO userDAO(EntityManager entityManager) {
        return new UserDAOImpl(entityManager);
    }

}
