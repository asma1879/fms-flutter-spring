package com.example.freelance_system.dao;

import java.util.List;

import com.example.freelance_system.model.Job;

public interface IJobDAO {
    void saveJob(Job job);
    List<Job> getJobsByClientId(Long clientId);
    List<Job> getAllJobs();
    Job getJobById(Long jobId);
    List<Object[]> getJobCountPerMonth();
}

