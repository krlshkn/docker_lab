package com.mypottery.pottery.controllers;

import com.mypottery.pottery.model.*;
import com.mypottery.pottery.model.Record;
import com.mypottery.pottery.repo.*;
import com.mypottery.pottery.service.AuthorizationService;
import com.mypottery.pottery.service.MainService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@CrossOrigin
public class MainController {

    @Autowired
    private MainService mainService;
    @Autowired
    private AuthorizationService authorizationService;
    @Autowired
    private RecordRepo recordRepo;
    @Autowired
    private AccountRepo customerRepo;
    @Autowired
    private OrderRepo orderRepo;
    @Autowired
    private ProductRepo productRepo;
    @Autowired
    private ProgramRepo programRepo;

    @Autowired
    private WorkerRepo workerRepo;

//добавление
    @PostMapping("/addproduct")
    public String addProduct(@RequestBody Product product){ productRepo.save(product); return "New product added";}

    @PostMapping("/addorder/{customer}/{product}")
    public String addOrder(@PathVariable("customer") int customer, @PathVariable("product") int product)
    { mainService.addOrder(customer, product); return "New order added";}

    @PostMapping("/addrecord/{program}/{date}/{time}/{customer}/{members}")
    public String addRecord(@PathVariable("program") int program, @PathVariable("date") String date, @PathVariable("time") int time, @PathVariable("customer") int customer, @PathVariable("members") int members)
   {  String[] ff = date.split("\\."); Record r = new Record(); r.setProgram(programRepo.findById(program));
       r.setDate(LocalDate.of(Integer.parseInt(ff[2]), Integer.parseInt(ff[1]), Integer.parseInt(ff[0])));
       r.setTime(time); r.setCustomer(customerRepo.findUserById(customer)); r.setMembers(members); r.setMaster(workerRepo.findById(2)); r.setAssistant(workerRepo.findById(7));
       recordRepo.save(r); return "New record added";}
//mainService.addRecord(program, date, time, customer, members
    @PostMapping("/adduser/{lastname}/{firstname}/{patronymic}/{gender}/{birthday}/{login}/{pwd}/{telephone}")
    public String addUser(@PathVariable("lastname") String lastName, @PathVariable("firstname") String firstName, @PathVariable("patronymic") String patronymic, @PathVariable("gender") String gender, @PathVariable("birthday") LocalDate birthday, @PathVariable("login") String login, @PathVariable("pwd") String pwd, @PathVariable("telephone") String telephone)
                         { Account c = new Account(); c.setFirstName(firstName); c.setLastName(lastName); c.setPatronymic(patronymic); c.setGender(gender); c.setBirthday(birthday);c.setLogin(login); c.setPwd(pwd); c.setRole("заказчик"); c.setTelephone(telephone);
                           customerRepo.save(c); return "New user added";}

//изменение
    @PutMapping("/updaterecord/{id}/{user}/{status}")
    public String updateRecord(@PathVariable("id") int id, @PathVariable("user") int user, @PathVariable("status") int status){ mainService.updateRecord(id, user, status);return "Record updated";}

    @PutMapping("/updateuser/{id}/{status}")
    public String updateUser(@PathVariable("id") int id, @PathVariable("status") String status){ mainService.updateUser(id, status);return "User updated";}

    @PutMapping("/updateorder/{id}/{status}")
    public String updateOrder(@PathVariable("id") int id, @PathVariable("status") String status){
        mainService.updateOrder(id, status);return "Order updated";
    }


//чтение
    @GetMapping("/finduser/{login}/{pwd}")
    public List<Account> findUser(@PathVariable("login") String login, @PathVariable("pwd") String pwd){return authorizationService.findUser(login, pwd);}

    @GetMapping("/user/{id}")
    public String getUser(@PathVariable("id") int id){ return customerRepo.findById(id).orElseThrow().toString();}

    @GetMapping("/getusers")
    public List<Account> getUsers(){return customerRepo.findAll();}

    @GetMapping("/record/{id}")
    public List<Record> getRecord(@PathVariable("id") int id){ return mainService.findByProgram(id);}

    @GetMapping("/getrecords")
    public List<Record> getRecords(){return recordRepo.findAll();}

    @GetMapping("/futurerecords")
    public List<Record> getFutureRecords(){return mainService.findFutureRecords();}

    @GetMapping("/freerecords")
    public List<Record> getFreeRecords(){return mainService.findLastRecords();}

    @GetMapping("/userrecords/{id}")
    public List<Record> getUserRecords(@PathVariable("id") int id){ return recordRepo.findByCustomerId(id);}

    @GetMapping("/userorders/{id}")
    public List<Order> getUserOrders(@PathVariable("id") int id){
        return orderRepo.findByCustomerId(id);
    }

    @GetMapping("/userlogin/{id}")
    public String getUserLogin(@PathVariable("id") int id){ return customerRepo.findById(id).orElseThrow().getLogin();}

    @GetMapping("/getprograms")
    public List<Program> getAllPrograms(){return programRepo.findAll();}

    @GetMapping("/getorders")
    public List<Order> getAllOrders(){return orderRepo.findAll();}

    @GetMapping("/getallproducts")
    public List<Product> getAllProducts(){return productRepo.findAll();}

    @GetMapping("/getproduct/{id}")
    public String getProduct(@PathVariable("id") int id){ return productRepo.findById(id).toString();}

    @GetMapping("/programname/{id}")
    public String getProgramName(@PathVariable("id") int id){ return programRepo.findById(id).getTitle();}

    @GetMapping("/getprogrambyname/{name}")
    public int getProgramByName(@PathVariable("name") String name){ return mainService.findProgramByName(name);}


//удаление
    @DeleteMapping("/deleterecord/{id}")
    public void deleteRecord(@PathVariable("id") int id){ recordRepo.deleteById(id);;}

}