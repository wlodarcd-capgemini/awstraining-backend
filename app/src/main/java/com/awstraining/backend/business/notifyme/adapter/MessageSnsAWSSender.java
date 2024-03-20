package com.awstraining.backend.business.notifyme.adapter;

import com.amazonaws.services.sns.AmazonSNS;
import com.amazonaws.services.sns.model.PublishRequest;
import com.amazonaws.services.sns.model.PublishResult;
import com.awstraining.backend.business.notifyme.MessageSender;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
public class MessageSnsAWSSender implements MessageSender {

    private static final Logger LOGGER = LogManager.getLogger(MessageSnsAWSSender.class);

    private String snsTopic;
    
    private AmazonSNS sns;

    @Autowired
    public MessageSnsAWSSender(@Value("${notification.topicarn}") String snsTopic, AmazonSNS sns) {
        this.snsTopic = snsTopic;
        this.sns = sns;
    }

    @Override
    public void send(String text) {
        // Publish message to the topic
        final PublishRequest publishRequest = new PublishRequest(snsTopic, text);
        final PublishResult publishResult = sns.publish(publishRequest);
        LOGGER.info("Message was send to topic '{}' with id '{}'.", snsTopic, publishResult.getMessageId());
    }
}
