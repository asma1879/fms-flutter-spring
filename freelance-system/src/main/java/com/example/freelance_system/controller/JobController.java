package com.example.freelance_system.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.freelance_system.dao.IJobDAO;
import com.example.freelance_system.dao.IUserDAO;
import com.example.freelance_system.model.Job;
import com.example.freelance_system.model.User;

@RestController
@RequestMapping("/api/auth/jobs")
@CrossOrigin("*")
public class JobController {

    @Autowired
    private IJobDAO jobDAO;

    @Autowired
    private IUserDAO userDAO;

    @PostMapping("/post")
    public ResponseEntity<String> postJob(@RequestBody Job job) {
        if (job.getClient() == null || job.getClient().getId() == null) {
            return ResponseEntity.badRequest().body("Client ID is required.");
        }

        User user = userDAO.getUserById(job.getClient().getId());
        if (user == null) {
            return ResponseEntity.badRequest().body("Invalid client ID.");
        }

        job.setClient(user); // ensure client is fully fetched entity
        jobDAO.saveJob(job);

        return ResponseEntity.ok("Job posted successfully.");
    }

    @GetMapping("/client/{clientId}")
    public List<Job> getJobsByClient(@PathVariable Long clientId) {
        return jobDAO.getJobsByClientId(clientId);
    }

    @GetMapping("/all")
    public List<Job> getAllJobs() {
        return jobDAO.getAllJobs();
    }
}

