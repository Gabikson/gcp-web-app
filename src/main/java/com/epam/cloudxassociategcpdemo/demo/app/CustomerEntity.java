package com.epam.cloudxassociategcpdemo.demo.app;

import lombok.Data;

import javax.persistence.Entity;
import javax.persistence.Id;

@Data
@Entity(name = "customers")
public class CustomerEntity {
    @Id
    private String id;
    private String owner;
    private String companyName;
}
