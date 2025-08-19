package com.example.freelance_system.daoimpl;

import org.springframework.stereotype.Repository;

import com.example.freelance_system.dao.IClientDAO;
import com.example.freelance_system.model.Client;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
@Repository
@Transactional
public class ClientDAOImpl implements IClientDAO{
	 @PersistenceContext
	    private EntityManager entityManager;

	    @Override
	    public Client getClientById(long id) {
	        return entityManager.find(Client.class, id);
	    }

	    @Override
	    public void updateClient(Client client) {
	        entityManager.merge(client);
	        entityManager.flush();
	    }
	    @Override
	    public void save(Client client) {
	        entityManager.merge(client);
	        entityManager.flush();
	    }

}
