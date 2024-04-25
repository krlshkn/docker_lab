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
@Table(name = "record")
public class Record {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "program", nullable = false)
    private Program program;

    @Column(name = "date", nullable = false)
    private LocalDate date;

    @Column(name = "\"time\"", nullable = false)
    private Integer time;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "master", nullable = false)
    private Worker master;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "assistant", nullable = false)
    private Worker assistant;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @OnDelete(action = OnDeleteAction.RESTRICT)
    @JoinColumn(name = "customer", nullable = false)
    private Account customer;

    @Column(name = "members", nullable = false)
    private Integer members;

    public Record(Program program, LocalDate date, int time, Worker master, Worker assistant, Account customer, int members) {
    }
    public Record(){};
/*
    TODO [JPA Buddy] create field to map the 'program_info' column
     Available actions: Define target Java type | Uncomment as is | Remove column mapping
    @Column(name = "program_info", columnDefinition = "program_info(0, 0)")
    private Object programInfo;
*/
}