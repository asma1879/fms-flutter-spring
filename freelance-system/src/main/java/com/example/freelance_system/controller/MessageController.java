package com.example.freelance_system.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import com.example.freelance_system.model.Message;
import com.example.freelance_system.service.MessageService;

@RestController
@RequestMapping("/api/auth/messages")
@CrossOrigin(origins = "*")
public class MessageController {

    @Autowired
    private MessageService messageService;

    @PostMapping("/send")
    public Message sendMessage(@RequestBody Message message) {
        return messageService.sendMessage(message);
    }

    @GetMapping("/between")
    public List<Message> getMessagesBetweenUsers(
            @RequestParam Long userId1,
            @RequestParam Long userId2) {
        return messageService.getMessagesBetweenUsers(userId1, userId2);
    }
}
