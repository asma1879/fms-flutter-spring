package com.example.freelance_system.dao;

import com.example.freelance_system.model.User;

public interface IUserDAO {
	User save(User user);
    User findByEmail(String email);
    User getUserById(long id);
    void updateUser(User user);
    User findById(long id);
    void update(User user);

}
