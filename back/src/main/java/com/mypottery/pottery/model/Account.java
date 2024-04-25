package com.mypottery.pottery.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
@Entity
@Table(name = "account")
public class Account {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Integer id;

    @Column(name = "role", nullable = false, length = 20)
    private String role;

    @Column(name = "status", length = 20)
    private String status;

    @Column(name = "login", nullable = false, length = 20)
    private String login;

    @Column(name = "pwd", nullable = false, length = 20)
    private String pwd;

    @Column(name = "first_name", nullable = false, length = 20)
    private String firstName;

    @Column(name = "last_name", nullable = false, length = 20)
    private String lastName;

    @Column(name = "patronymic", length = 30)
    private String patronymic;

    @Column(name = "gender", nullable = false, length = 10)
    private String gender;

    @Column(name = "birthday", nullable = false)
    private LocalDate birthday;

    @Column(name = "telephone", length = 12)
    private String telephone;

}