package com.example.freelance_system.dao;

import com.example.freelance_system.model.FreelancerProfile;

public interface IFreelancerProfileDAO {
	FreelancerProfile saveOrUpdate(FreelancerProfile profile);
    FreelancerProfile getByUserId(Long userId);

}
