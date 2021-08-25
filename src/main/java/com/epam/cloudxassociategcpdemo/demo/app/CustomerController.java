package com.epam.cloudxassociategcpdemo.demo.app;

import lombok.RequiredArgsConstructor;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpServletRequest;
import java.util.UUID;

@RequestMapping("/")
@Controller
@RequiredArgsConstructor
public class CustomerController {
    private final CustomerDao customerDao;

    @GetMapping
    public String getCustomers(HttpServletRequest request) {
        Iterable<CustomerEntity> customers = customerDao.findAll();

        request.setAttribute("customers", customers);

        return "index.html";
    }

    @PostMapping
    public String addCustomer(CustomerEntity customerEntity) {
        customerEntity.setId(UUID.randomUUID().toString());
        customerDao.save(customerEntity);

        return "redirect:";
    }

    @GetMapping("/add-customer")
    public String newCustomer() {
        return "customer-item.html";
    }

    @GetMapping("/delete-customer")
    public String deleteCustomer(@Param("id") String id) {
        customerDao.deleteById(id);

        return "redirect:";
    }

}
