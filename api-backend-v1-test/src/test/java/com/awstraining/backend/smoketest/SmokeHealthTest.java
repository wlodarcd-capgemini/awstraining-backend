package com.awstraining.backend.smoketest;

import static java.net.URI.create;
import static java.net.http.HttpClient.Version.HTTP_1_1;
import static java.net.http.HttpClient.newBuilder;
import static java.net.http.HttpResponse.BodyHandlers.ofString;
import static java.time.Duration.ofSeconds;
import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import org.junit.jupiter.api.Test;

class SmokeHealthTest {

    @Test
    void shouldTestHealthPing() throws IOException, InterruptedException {
        checkPath2Ok("health/ping");
    }

    @Test
    void shouldTestHealth() throws IOException, InterruptedException {
        checkPath2Ok("health");
    }

    @Test
    void shouldTestPrometheus() throws IOException, InterruptedException {
        checkPath2Ok("prometheus");
    }

    private void checkPath2Ok(final String path) throws IOException, InterruptedException {
        final String url = new PropertyHandler().getUrl();

        final HttpClient httpClient = newBuilder().version(HTTP_1_1).connectTimeout(ofSeconds(10)).build();

        final HttpRequest request = HttpRequest.newBuilder().GET().uri(create(url + "/status/v1/" + path)).build();

        final HttpResponse<String> response = httpClient.send(request, ofString());

        assertThat(response.statusCode()).isEqualTo(200);
    }
}
