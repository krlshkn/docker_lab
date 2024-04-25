package com.mypottery.pottery.repo;

import com.mypottery.pottery.model.Program;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProgramRepo extends JpaRepository<Program, Integer> {
    Program findByTitle(String title);
    Program findById(int id);

}
