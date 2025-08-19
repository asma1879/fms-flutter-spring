package com.example.freelance_system.controller;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.freelance_system.dao.IBidDAO;
import com.example.freelance_system.dao.IJobDAO;
import com.example.freelance_system.model.Job;

@RestController
@RequestMapping("/api/auth/charts")
@CrossOrigin(origins = "*")
public class ChartController {

    @Autowired
    private IJobDAO jobDAO;

    @Autowired
    private IBidDAO bidDAO;

    @GetMapping("/jobs-per-month")
    public Map<Integer, Long> getJobsPerMonth() {
        List<Job> jobs = jobDAO.getAllJobs();
        return jobs.stream()
                   .map(j -> LocalDate.parse(j.getDeadline()))
                   .collect(Collectors.groupingBy(
                       LocalDate::getMonthValue, Collectors.counting()
                   ));
    }


    @GetMapping("/bids-by-status")
    public List<Map<String, Object>> getBidsByStatus() {
        List<Object[]> results = bidDAO.getBidCountByStatus();
        List<Map<String, Object>> response = new ArrayList<>();
        for (Object[] row : results) {
            Map<String, Object> map = new HashMap<>();
            map.put("status", row[0]);
            map.put("count", row[1]);
            response.add(map);
        }
        return response;
    }
}
