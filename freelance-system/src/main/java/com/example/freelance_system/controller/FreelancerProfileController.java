package com.example.freelance_system.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.example.freelance_system.model.FreelancerProfile;
import com.example.freelance_system.service.FreelancerProfileService;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@RestController
@RequestMapping("/api/auth/freelancer/profile")
@CrossOrigin
public class FreelancerProfileController {
	 @Autowired
	    private FreelancerProfileService profileService;

	    private static final String UPLOAD_DIR = "uploads/profile_images/";

	    @PostMapping("/update")
	    public ResponseEntity<FreelancerProfile> updateProfile(@RequestBody FreelancerProfile profile) {
	        return ResponseEntity.ok(profileService.saveOrUpdate(profile));
	    }

//	    @GetMapping("/{userId}")
//	    public ResponseEntity<FreelancerProfile> getProfile(@PathVariable Long userId) {
//	        return ResponseEntity.ok(profileService.getByUserId(userId));
//	    }
	    @GetMapping("/{userId}")
	    public ResponseEntity<?> getProfile(@PathVariable Long userId) {
	        FreelancerProfile profile = profileService.getByUserId(userId);
	        if (profile == null) {
	            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("No profile found");
	        }
	        return ResponseEntity.ok(profile);
	    }


	    @PostMapping("/upload-image")
	    public ResponseEntity<String> uploadImage(@RequestParam("file") MultipartFile file) {
	        if (file.isEmpty()) {
	            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("File is empty");
	        }

	        try {
	            String filename = UUID.randomUUID().toString() + "_" + StringUtils.cleanPath(file.getOriginalFilename());
	            Path path = Paths.get(UPLOAD_DIR + filename);
	            Files.createDirectories(path.getParent());
	            Files.write(path, file.getBytes());
	            return ResponseEntity.ok("/" + UPLOAD_DIR + filename);
	        } catch (IOException e) {
	            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Upload failed");
	        }
	    }

}
