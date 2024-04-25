package com.mypottery.pottery.repo;

import com.mypottery.pottery.model.Product;
import com.mypottery.pottery.model.Program;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProductRepo extends JpaRepository<Product, Integer>{
    Product findById(int id);
}
