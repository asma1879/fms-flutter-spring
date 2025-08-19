package com.example.freelance_system.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.freelance_system.dao.IClientDAO;
import com.example.freelance_system.dao.IFreelancerDAO;
import com.example.freelance_system.dao.IUserDAO;
import com.example.freelance_system.model.Client;
import com.example.freelance_system.model.Freelancer;
import com.example.freelance_system.model.User;

@RestController
@CrossOrigin("*")
@RequestMapping("/api/auth/wallet")
public class WalletController {
	
	@Autowired
    private IClientDAO clientDAO;

    @Autowired
    private IFreelancerDAO freelancerDAO;

    @GetMapping("/client/{id}")
    public ResponseEntity<Double> getClientWallet(@PathVariable long id) {
        Client client = clientDAO.getClientById(id);
        if (client != null) {
            return ResponseEntity.ok(client.getWalletBalance());
        } else {
            return ResponseEntity.notFound().build(); // 404 if client not found
        }
    }

    @GetMapping("/freelancer/{id}")
    public ResponseEntity<Double> getFreelancerWallet(@PathVariable int id) {
        Freelancer freelancer = freelancerDAO.getFreelancerById(id);
        if (freelancer != null) {
            return ResponseEntity.ok(freelancer.getWalletBalance());
        } else {
            return ResponseEntity.notFound().build(); // 404 if freelancer not found
        }
    }
    @Autowired
    private IUserDAO userDAO;

    @GetMapping("/user/{id}")
    public ResponseEntity<Double> getUserWallet(@PathVariable long id) {
        User user = userDAO.getUserById(id);
        if (user != null) {
            return ResponseEntity.ok(user.getWalletBalance());
        }
        return ResponseEntity.notFound().build();
    }

}
