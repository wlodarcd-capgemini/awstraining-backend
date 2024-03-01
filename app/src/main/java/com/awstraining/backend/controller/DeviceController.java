package com.awstraining.backend.controller;

import com.awstraining.backend.api.rest.v1.DeviceIdApi;
import com.awstraining.backend.api.rest.v1.model.Measurement;
import com.awstraining.backend.api.rest.v1.model.Measurements;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("device/v1")
class DeviceController implements DeviceIdApi {
    @Override
    public ResponseEntity<Void> publishMeasurements(final String deviceId, final Measurement measurement) {
        return new ResponseEntity<>(HttpStatus.NOT_IMPLEMENTED);
    }

    @Override
    public ResponseEntity<Measurements> retrieveMeasurements(final String deviceId) {
        return new ResponseEntity<>(HttpStatus.NOT_IMPLEMENTED);
    }
}
