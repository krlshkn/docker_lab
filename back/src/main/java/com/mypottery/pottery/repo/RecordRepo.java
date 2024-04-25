package com.mypottery.pottery.repo;

import com.mypottery.pottery.model.Program;
import com.mypottery.pottery.model.Record;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RecordRepo extends JpaRepository<Record, Integer> {
    List<Record> findByCustomerId(int customer);
//    List<Record> findByStatus(int status);
//    List<Record> findByProgram(int program);
    Record findRecordById(int id);

}
