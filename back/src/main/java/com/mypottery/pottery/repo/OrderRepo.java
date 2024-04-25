package com.mypottery.pottery.repo;

import com.mypottery.pottery.model.Account;
import com.mypottery.pottery.model.Order;
import com.mypottery.pottery.model.Product;
import com.mypottery.pottery.model.Record;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderRepo extends JpaRepository<Order, Integer> {
    List<Order> findByCustomerId(int id);
    Order findOrderById(int id);

}
