package com.awstraining.backend;

import static org.springframework.boot.Banner.Mode.OFF;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class Application {
    private static final Logger LOGGER = LoggerFactory.getLogger(Application.class);

    public static void main(final String[] args) {
        try {
            new SpringApplicationBuilder(Application.class).bannerMode(OFF).run(args).start();
        } catch (final Throwable e) {
            LOGGER.error("Error while starting the app.", e);
        }
    }

}
