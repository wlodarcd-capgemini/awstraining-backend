package com.awstraining.backend.business.notifyme.adapter;

import com.amazonaws.services.translate.AmazonTranslate;
import com.amazonaws.services.translate.model.TranslateTextRequest;
import com.amazonaws.services.translate.model.TranslateTextResult;
import com.awstraining.backend.business.notifyme.NotifyMeDO;
import com.awstraining.backend.business.notifyme.Translator;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class TranslatorImpl implements Translator {

    private static final Logger LOGGER = LogManager.getLogger(TranslatorImpl.class);
    

    
    // TODO: lab2
    //  1. Inject AWS AmazonTranslate from configuration TranslatorConfig.
    private AmazonTranslate amazonTranslate;

    @Autowired
    public TranslatorImpl(final AmazonTranslate amazonTranslate) {

        this.amazonTranslate = amazonTranslate;
    }
    
    @Override
    public String translate(NotifyMeDO notifyMeDO) {
        // TODO: lab2
        //  1. Create translate text request.
        //  2. Call translate.
        //  3. Log information about successful translated message.
        //  4. Return translated message

        TranslateTextRequest textRequest = new TranslateTextRequest();
        textRequest.setText(notifyMeDO.text());
        textRequest.setSourceLanguageCode(notifyMeDO.sourceLc());
        textRequest.setTargetLanguageCode(notifyMeDO.targetLc());

        TranslateTextResult translateTextResult = amazonTranslate.translateText(textRequest);

        LOGGER.info("Message {} was successfully translated form language {} to {}", notifyMeDO.text(), notifyMeDO.sourceLc(), notifyMeDO.targetLc());
        return translateTextResult.getTranslatedText();
    }
}
