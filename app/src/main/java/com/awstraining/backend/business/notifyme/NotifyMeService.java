package com.awstraining.backend.business.notifyme;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class NotifyMeService {

    // TODO: lab1
    //  1. Inject MessageSender.
    private MessageSender messageSender;
    // TODO lab2
    //  1. Inject Translator
    private Translator translator;
    // TODO lab3
    //  1. Inject sentiment detector
    @Autowired
    public NotifyMeService(final MessageSender messageSender, final Translator translator) {

        this.messageSender = messageSender;
        this.translator = translator;
    }
    
    public String notifyMe(NotifyMeDO notifyMe) {
      
        // TODO: lab1
        //  1. Send text using sender.
        //  2. Return sent message.
//        messageSender.send(notifyMe.text());
        // TODO: lab2
        //  1. Translate text from using translator.
        //  2. Change sending of text to "translated text" and return it.
        messageSender.send(translator.translate(notifyMe));

        // TODO: lab3
        //  1. Detect sentiment of translated message.
        //  2. Change sending of text to "setiment: translated text" and return it.
        return notifyMe.text();
    }
    
}
