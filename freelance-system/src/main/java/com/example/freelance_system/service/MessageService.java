package com.example.freelance_system.service;

import java.util.List;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;

import org.springframework.stereotype.Service;

import com.example.freelance_system.model.Message;

@Service
@Transactional
public class MessageService {

    @PersistenceContext
    private EntityManager entityManager;

    public Message sendMessage(Message message) {
        entityManager.persist(message);
        return message;
    }

    public List<Message> getMessagesBetweenUsers(Long userId1, Long userId2) {
        return entityManager.createQuery(
                "SELECT m FROM Message m WHERE " +
                "(m.sender.id = :userId1 AND m.receiver.id = :userId2) OR " +
                "(m.sender.id = :userId2 AND m.receiver.id = :userId1) " +
                "ORDER BY m.timestamp ASC", Message.class)
                .setParameter("userId1", userId1)
                .setParameter("userId2", userId2)
                .getResultList();
    }
}
