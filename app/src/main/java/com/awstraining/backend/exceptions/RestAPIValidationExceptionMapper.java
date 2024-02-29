package com.awstraining.backend.exceptions;

import static org.springframework.core.Ordered.HIGHEST_PRECEDENCE;

import javax.servlet.http.HttpServletRequest;

import com.awstraining.backend.api.rest.v1.model.ApiBusinessErrorResponse;
import com.awstraining.backend.business.exceptions.UnknownDeviceException;
import org.springframework.core.annotation.Order;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@Order(HIGHEST_PRECEDENCE)
@ControllerAdvice
public class RestAPIValidationExceptionMapper {

    @ExceptionHandler(UnknownDeviceException.class)
    public ResponseEntity<ApiBusinessErrorResponse> toResponse(final HttpServletRequest request,
                                                               final UnknownDeviceException unknownDeviceException) {

        return unknownDeviceException.toResponse(request);
    }
}

