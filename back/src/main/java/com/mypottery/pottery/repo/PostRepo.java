package com.mypottery.pottery.repo;

import com.mypottery.pottery.model.Post;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PostRepo extends JpaRepository<Post, Integer> {
}