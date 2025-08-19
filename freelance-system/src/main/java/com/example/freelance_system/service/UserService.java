package com.example.freelance_system.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;

import com.example.freelance_system.dao.IUserDAO;
import com.example.freelance_system.model.User;
import org.springframework.stereotype.Service;

@Service
public class UserService {
	 @Autowired
	    private IUserDAO userDAO;

	    @Autowired
	    private PasswordEncoder passwordEncoder;

	    public User register(User user) {
	        //user.setPassword(passwordEncoder.encode(user.getPassword()));
	        return userDAO.save(user);
	    }

	    public User login(String email, String rawPassword) {
	        User existing = userDAO.findByEmail(email);
	        if (existing != null && rawPassword.equals(existing.getPassword())) {
	            return existing;
	        }
	        return null;
	    }

}
