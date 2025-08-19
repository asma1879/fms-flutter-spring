package com.example.freelance_system.dao;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.example.freelance_system.dto.ReviewDTO;
import com.example.freelance_system.model.Review;

public interface IReviewDAO extends JpaRepository<Review, Long> {

    List<Review> findByRevieweeId(Long revieweeId);
    List<Review> findByReviewerId(Long reviewerId);

    // Reviews about freelancer (reviewee = freelancer)
    @Query("SELECT new com.example.freelance_system.dto.ReviewDTO(" +
            "r.id, r.rating, r.feedback, u.name, j.title, r.reviewTime) " +
           "FROM Review r " +
           "JOIN User u ON r.reviewerId = u.id " +
           "JOIN Job j ON r.jobId = j.id " +
           "WHERE r.revieweeId = :revieweeId")
    List<ReviewDTO> findDetailedReviewsByRevieweeId(@Param("revieweeId") Long revieweeId);

    // Reviews about client (reviewee = client)
    @Query("SELECT new com.example.freelance_system.dto.ReviewDTO(" +
            "r.id, r.rating, r.feedback, u.name, j.title, r.reviewTime) " +
           "FROM Review r " +
           "JOIN User u ON r.reviewerId = u.id " +
           "JOIN Job j ON r.jobId = j.id " +
           "WHERE r.revieweeId = :clientId")
    List<ReviewDTO> findDetailedReviewsForClient(@Param("clientId") Long clientId);
}
