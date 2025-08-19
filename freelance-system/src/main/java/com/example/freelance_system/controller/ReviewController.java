package com.example.freelance_system.controller;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.freelance_system.dao.IReviewDAO;
import com.example.freelance_system.dto.ReviewDTO;
import com.example.freelance_system.model.Review;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api/auth/reviews")
public class ReviewController {

    @Autowired
    private IReviewDAO reviewDAO;

    @PostMapping
    public ResponseEntity<Review> addReview(@RequestBody Review review) {
        review.setReviewTime(LocalDateTime.now());
        Review saved = reviewDAO.save(review);
        return ResponseEntity.ok(saved);
    }

    // Simple reviews about a user (freelancer or client)
    @GetMapping("/reviewee/{id}")
    public List<Review> getReviewsForUser(@PathVariable Long id) {
        return reviewDAO.findByRevieweeId(id);
    }

    // Simple reviews written by a user
    @GetMapping("/reviewer/{id}")
    public List<Review> getReviewsByUser(@PathVariable Long id) {
        return reviewDAO.findByReviewerId(id);
    }
    
    // Detailed reviews about a freelancer (includes client name and job title)
    @GetMapping("/detailed/reviewee/{id}")
    public List<ReviewDTO> getDetailedReviewsForUser(@PathVariable Long id) {
        return reviewDAO.findDetailedReviewsByRevieweeId(id);
    }

    // Detailed reviews about a client (includes freelancer name and job title)
    @GetMapping("/detailed/client/{id}")
    public List<ReviewDTO> getDetailedReviewsForClient(@PathVariable Long id) {
        return reviewDAO.findDetailedReviewsForClient(id);
    }
}
