package com.example.freelance_system.controller;

import com.example.freelance_system.dao.IWishlistDAO;
import com.example.freelance_system.model.Job;
import com.example.freelance_system.model.Wishlist;

import jakarta.persistence.EntityManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/auth/wishlist")
@CrossOrigin(origins = "*")
public class WishlistController {

    @Autowired
    private IWishlistDAO wishlistDAO;

    @Autowired
    private EntityManager entityManager;

    @PostMapping("/add")
    public Wishlist addToWishlist(@RequestBody Wishlist wishlist) {
        Job job = entityManager.find(Job.class, wishlist.getJob().getId());
        wishlist.setJob(job);  // attach managed job
        return wishlistDAO.save(wishlist);
    }

    @GetMapping("/{userId}")
    public List<Wishlist> getWishlistByUserId(@PathVariable Long userId) {
        return wishlistDAO.getAllByUserId(userId);
    }

    @DeleteMapping("/{id}")
    public void deleteWishlist(@PathVariable Long id) {
        wishlistDAO.deleteById(id);
    }
}
