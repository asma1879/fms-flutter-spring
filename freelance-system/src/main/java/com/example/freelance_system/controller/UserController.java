package com.example.freelance_system.controller;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.freelance_system.dao.IClientDAO;
import com.example.freelance_system.model.Client;
import com.example.freelance_system.model.User;
import com.example.freelance_system.service.UserService;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin
public class UserController {
	 @Autowired
	    private UserService userService;
	 @Autowired
	 private IClientDAO clientDAO;


//	    @PostMapping("/register")
//	    public User register(@RequestBody User user) {
//	        return userService.register(user);
//	    }
	 
	 @PostMapping("/register")
	 public User register(@RequestBody User user) {
	     User savedUser = userService.register(user); // Save to users table

	     // 👇 Insert into clients or freelancers table based on role
	     if ("CLIENT".equalsIgnoreCase(savedUser.getRole())) {
	         Client client = new Client();
	         client.setId(savedUser.getId()); // Same ID as User
	         client.setName(savedUser.getName());
	         client.setEmail(savedUser.getEmail());
	         client.setWalletBalance(0.0);
	         clientDAO.save(client); // Save to clients table
	     }

	     // Similarly for freelancer role if needed

	     return savedUser;
	 }


	    @PostMapping("/login")
	    public ResponseEntity<?> login(@RequestBody User user) {
	        User result = userService.login(user.getEmail(), user.getPassword());
	        if (result == null) {
	            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
	                    .body(Map.of("error", "Invalid credentials"));
	        }

	        result.setPassword(null); // 🔐 Never return the password
	        return ResponseEntity.ok(Map.of(
	        		//"user", result
	        		 "id", result.getId(),
	        	        "name", result.getName(),
	        	        "email", result.getEmail(),
	        	        "role", result.getRole()
	        		));
	    }
	    @GetMapping("/hello")
	    public String hello() {
	        return "Backend is running ✅";
	    }


}
