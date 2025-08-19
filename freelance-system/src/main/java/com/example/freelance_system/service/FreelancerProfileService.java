package com.example.freelance_system.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.freelance_system.dao.IFreelancerProfileDAO;
import com.example.freelance_system.model.FreelancerProfile;

@Service
public class FreelancerProfileService {
	@Autowired
    private IFreelancerProfileDAO profileDAO;

    public FreelancerProfile saveOrUpdate(FreelancerProfile profile) {
        return profileDAO.saveOrUpdate(profile);
    }

    public FreelancerProfile getByUserId(Long userId) {
        return profileDAO.getByUserId(userId);
    }

}
