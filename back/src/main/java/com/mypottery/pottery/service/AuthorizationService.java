package com.mypottery.pottery.service;

import com.mypottery.pottery.model.Account;
import com.mypottery.pottery.repo.AccountRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AuthorizationService {
    @Autowired
    private AccountRepo accountRepo;

//    public Customer findUser(String login, String pwd) {
//        Customer c = customerRepo.findByLogin(login);
//        if (c != null && c.getPwd().equals(pwd)) return c;
//        return customerRepo.findByRole("guest");
//    }
    public List<Account> findUser(String login, String pwd) {
        List<Account> cus = accountRepo.findByLogin(login);
        for(Account c: cus){
        if (c != null && c.getPwd().equals(pwd)) return cus;}
        return accountRepo.findByRole("гость");
    }

    public boolean checkLogin(String login) {
        List<Account> c = accountRepo.findByLogin(login);
        if (c != null) return true;
        return false;
    }
}
