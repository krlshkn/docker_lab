package com.mypottery.pottery.repo;

import com.mypottery.pottery.model.Worker;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WorkerRepo extends JpaRepository<Worker, Integer> {
    Worker findById(int id);
}