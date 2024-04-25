package com.mypottery.pottery.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDate;
import java.util.Optional;

@Getter
@Setter
@Entity
@Table(name = "orderr")
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Integer id;

    @Column(name = "date", nullable = false)
    private LocalDate date;

    @ManyToOne(fetch = FetchType.LAZY)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "customer")
    private Account customer;


    @ManyToOne(fetch = FetchType.LAZY)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "product")
    private Product product;

    @Column(name = "status", length = 20)
    private String status;

    @Column(name = "note", length = Integer.MAX_VALUE)
    private String note;

    public Order(Account customer, Product product) {
    }

    public Order(){};
/*
    TODO [JPA Buddy] create field to map the 'product_info' column
     Available actions: Define target Java type | Uncomment as is | Remove column mapping
    @Column(name = "product_info", columnDefinition = "product_info(0, 0)")
    private Object productInfo;
*/
}