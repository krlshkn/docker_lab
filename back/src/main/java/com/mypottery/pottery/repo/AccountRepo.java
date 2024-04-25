package com.mypottery.pottery.repo;

import com.mypottery.pottery.model.Account;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AccountRepo extends JpaRepository<Account, Integer> {
    List<Account> findByRole(String role);
    List<Account> findByLogin(String login);
    Account findUserById(int id);
}