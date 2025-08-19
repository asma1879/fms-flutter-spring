package com.example.freelance_system.dao;

import com.example.freelance_system.model.Client;

public interface IClientDAO {
	Client getClientById(long id);
    void updateClient(Client client);
    void save(Client client);

}
