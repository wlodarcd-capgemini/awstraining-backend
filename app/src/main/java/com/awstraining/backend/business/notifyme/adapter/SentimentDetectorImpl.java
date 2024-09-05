package com.awstraining.backend.business.notifyme.adapter;

import com.amazonaws.services.comprehend.AmazonComprehend;
import com.amazonaws.services.comprehend.model.DetectSentimentRequest;
import com.amazonaws.services.comprehend.model.DetectSentimentResult;
import com.awstraining.backend.business.notifyme.Sentiment;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class SentimentDetectorImpl implements Sentiment {

    private static final Logger LOGGER = LogManager.getLogger(SentimentDetectorImpl.class);
    

    
    // TODO: lab3
    //  1. Inject AWS AmazonComprehend from configuration ComprehendSentimentConfig.
    private final AmazonComprehend amazonComprehend;

    @Autowired
    public SentimentDetectorImpl(final AmazonComprehend amazonComprehend) {

        this.amazonComprehend = amazonComprehend;
    }

    // TODO: lab3
    //  1. Create detect sentiment text request.
    //  2. Call detection.
    //  3. Log information about sentiment.
    //  4. Return sentiment.
    @Override
    public String detectSentiment(String language, String text) {
        DetectSentimentRequest detectSentimentRequest = new DetectSentimentRequest()
                .withText(text)
                .withLanguageCode(language);

        final DetectSentimentResult detectSentimentResult = amazonComprehend.detectSentiment(detectSentimentRequest);

        final String sentiment = detectSentimentResult.getSentiment();
        LOGGER.info("Detected sentiment {} in the message {}", text, sentiment);
        return sentiment;
    }
}
