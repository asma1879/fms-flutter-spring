package com.example.freelance_system.dao;

import java.util.List;

import com.example.freelance_system.model.Wishlist;

public interface IWishlistDAO {
    Wishlist save(Wishlist wishlist);
    List<Wishlist> getAllByUserId(Long userId);
    void deleteById(Long id);
}
