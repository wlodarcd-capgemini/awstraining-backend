package com.awstraining.backend.business.notifyme.controller;

import com.awstraining.backend.api.rest.v1.NotifyMeApi;
import com.awstraining.backend.api.rest.v1.model.NotifyMe;
import com.awstraining.backend.api.rest.v1.model.SentMessage;
import com.awstraining.backend.business.notifyme.NotifyMeDO;
import com.awstraining.backend.business.notifyme.NotifyMeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("notification/v1")
public class NotifyMeController implements NotifyMeApi {

    private final NotifyMeService service;

    @Autowired
    public NotifyMeController(final NotifyMeService service) {
        this.service = service;
    }
    
    @Override
    public ResponseEntity<SentMessage> notifyMe(NotifyMe notifyMe) {
        final NotifyMeDO notifyMeDO = map(notifyMe);
        final String message = service.notifyMe(notifyMeDO);
        return ResponseEntity.ok(map(message));
    }

    private static SentMessage map(String message) {
        return new SentMessage().text(message);
    }

    private NotifyMeDO map(NotifyMe notifyMe) {
        return new NotifyMeDO(notifyMe.getText(), notifyMe.getSourceLc(), notifyMe.getTargetLc());
    }
}
