package com.example.freelance_system.dao;

import com.example.freelance_system.model.Freelancer;

public interface IFreelancerDAO {
	Freelancer getFreelancerById(int id);
    void updateFreelancer(Freelancer freelancer);

}
