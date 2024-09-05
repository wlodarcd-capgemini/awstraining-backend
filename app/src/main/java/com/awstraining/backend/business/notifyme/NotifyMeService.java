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
    private Sentiment sentiment;
    @Autowired
    public NotifyMeService(final MessageSender messageSender, final Translator translator, final Sentiment sentiment) {

        this.messageSender = messageSender;
        this.translator = translator;
        this.sentiment = sentiment;
    }
    
    public String notifyMe(NotifyMeDO notifyMe) {
      
        // TODO: lab1
        //  1. Send text using sender.
        //  2. Return sent message.
//        messageSender.send(notifyMe.text());
        // TODO: lab2
        //  1. Translate text from using translator.
        //  2. Change sending of text to "translated text" and return it.
        final String translatedMessage = translator.translate(notifyMe);

        // TODO: lab3
        //  1. Detect sentiment of translated message.
        //  2. Change sending of text to "setiment: translated text" and return it.
        final String sentimentStr = sentiment.detectSentiment(notifyMe.sourceLc(), notifyMe.text());
        final String result = String.format("%s: %s", sentimentStr, translatedMessage);

        messageSender.send(result);

        return result;
    }
    
}
