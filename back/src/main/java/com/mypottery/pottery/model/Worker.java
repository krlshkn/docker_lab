package com.mypottery.pottery.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.OnDelete;
import org.hibernate.annotations.OnDeleteAction;

import java.time.LocalDate;

@Getter
@Setter
@Entity
@Table(name = "worker")
public class Worker {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Integer id;

    @Column(name = "first_name", nullable = false, length = 20)
    private String firstName;

    @Column(name = "last_name", nullable = false, length = 20)
    private String lastName;

    @Column(name = "patronymic", length = 30)
    private String patronymic;

    @Column(name = "passport", nullable = false, length = 10)
    private String passport;

    @Column(name = "gender", nullable = false, length = 10)
    private String gender;

    @Column(name = "birthday", nullable = false)
    private LocalDate birthday;

    @Column(name = "telephone", length = 12)
    private String telephone;

    @ManyToOne(fetch = FetchType.LAZY)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "post")
    private Post post;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "kurator")
    private Worker kurator;

/*
    TODO [JPA Buddy] create field to map the 'fio' column
     Available actions: Define target Java type | Uncomment as is | Remove column mapping
    @Column(name = "fio", columnDefinition = "fio(0, 0)")
    private Object fio;
*/
}