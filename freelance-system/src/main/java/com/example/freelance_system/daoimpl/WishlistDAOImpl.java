package com.example.freelance_system.daoimpl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.example.freelance_system.dao.IWishlistDAO;
import com.example.freelance_system.model.Wishlist;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import jakarta.transaction.Transactional;

@Repository
@Transactional
public class WishlistDAOImpl implements IWishlistDAO {

    @Autowired
    private EntityManager entityManager;

    @Override
    public Wishlist save(Wishlist wishlist) {
        return entityManager.merge(wishlist);
    }

    @Override
    public List<Wishlist> getAllByUserId(Long userId) {
        String jpql = "SELECT w FROM Wishlist w WHERE w.userId = :userId";
        TypedQuery<Wishlist> query = entityManager.createQuery(jpql, Wishlist.class);
        query.setParameter("userId", userId);
        return query.getResultList();
    }

    @Override
    public void deleteById(Long id) {
        Wishlist wishlist = entityManager.find(Wishlist.class, id);
        if (wishlist != null) {
            entityManager.remove(wishlist);
        }
    }
}
