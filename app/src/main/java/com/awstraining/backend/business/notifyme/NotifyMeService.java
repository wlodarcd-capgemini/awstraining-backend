package com.awstraining.backend.business.notifyme;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class NotifyMeService {
    
    private MessageSender sender;
    
    private Translator translator;
    
    private Sentiment sentimentDetector;

    @Autowired
    public NotifyMeService(MessageSender sender, Translator translator, Sentiment sentimentAssessor) {
        this.sender = sender;
        this.translator = translator;
        this.sentimentDetector = sentimentAssessor;
    }
    
    public String notifyMe(NotifyMeDO notifyMe) {
        final String translatedMessage = translator.translate(notifyMe);
        final String sentiment = sentimentDetector.detectSentiment(notifyMe.targetLc(), translatedMessage);
        final String sentMessage = sentiment + ": " + translatedMessage;
        sender.send(sentMessage);
        return sentMessage;
    }
    
}
