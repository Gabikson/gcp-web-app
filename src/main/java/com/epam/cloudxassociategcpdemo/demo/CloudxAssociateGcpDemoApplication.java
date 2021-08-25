package com.epam.cloudxassociategcpdemo.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@EnableJpaRepositories
@SpringBootApplication
public class CloudxAssociateGcpDemoApplication {

	public static void main(String[] args) {
		SpringApplication.run(CloudxAssociateGcpDemoApplication.class, args);
	}

}
