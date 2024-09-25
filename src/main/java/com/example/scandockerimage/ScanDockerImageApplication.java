package com.example.scandockerimage;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ScanDockerImageApplication {

    public static void main(String[] args) {
        SpringApplication.run(ScanDockerImageApplication.class, args);

        System.out.println("Docker World");
    }

}
