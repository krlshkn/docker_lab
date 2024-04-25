package com.mypottery.pottery.service;

import com.mypottery.pottery.model.Account;
import com.mypottery.pottery.model.Order;
import com.mypottery.pottery.model.Program;
import com.mypottery.pottery.model.Record;
import com.mypottery.pottery.repo.*;
import org.hibernate.type.descriptor.java.LocalDateJavaType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cglib.core.Local;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.Date;
import java.util.List;
import java.util.Locale;

@Service
public class MainService {

    @Autowired
    private ProductRepo productRepo;

    @Autowired
    private OrderRepo orderRepo;

    @Autowired
    private ProgramRepo programRepo;

    @Autowired
    private RecordRepo recordRepo;

    @Autowired
    private AccountRepo accountRepo;

    @Autowired
    private WorkerRepo workerRepo;

    public List<Record> findByProgram(int program){
        List<Record> recs= recordRepo.findAll();;
        List<Record> filterrecs = recs.stream()
                .filter(r -> r.getProgram().getId() == program)
                .filter(i -> LocalDate.now().isBefore(i.getDate()))
                .toList();
        return filterrecs;
    }

    public void updateRecord(int id, int user, int status){
        Record okRecord = recordRepo.findRecordById(id);
//        okRecord.setStatus(status);
        okRecord.setCustomer(accountRepo.getReferenceById(user));
//        okRecord.setCustomer(user);
        recordRepo.save(okRecord);
    }

    public void addRecord(int program, String date, int time, int customer, int members){
        String[] ff = date.split("\\.");
        Record new_record = new Record(programRepo.findById(program), LocalDate.of(Integer.parseInt(ff[2]), Integer.parseInt(ff[1]), Integer.parseInt(ff[0])), time, workerRepo.findById(2), workerRepo.findById(4), accountRepo.findUserById(customer), members);
    }

    public void addOrder(int customer, int product){
        Order new_order = new Order();
        new_order.setCustomer(accountRepo.findUserById(customer));
        new_order.setProduct(productRepo.findById(product));
        new_order.setStatus("в обработке");
        new_order.setDate(LocalDate.now());
        orderRepo.save(new_order);
    }

    public void updateOrder(int id, String status){
        Order okOrder = orderRepo.findOrderById(id);
        okOrder.setStatus(status);
        orderRepo.save(okOrder);
    }
    public void updateUser(int id, String status){
        Account okCustomer = accountRepo.findUserById(id);
        okCustomer.setStatus(status);
        accountRepo.save(okCustomer);
    }
    public List<Record> findFutureRecords(){
        List<Record> recs = recordRepo.findAll();
        List<Record> future = recs.stream()
                .filter(i -> LocalDate.now().isBefore(i.getDate()) || LocalDate.now().isEqual(i.getDate()))
                .toList();
        return future;
    }
    public List<Record> findLastRecords(){
        List<Record> recs = recordRepo.findAll();
        List<Record> future = recs.stream()
                .filter(i -> LocalDate.now().isAfter(i.getDate()))
                .toList();
        return future;
    }
    public int findProgramByName(String name){
        Program p = programRepo.findByTitle(name);
        return p.getId();
    }

}
