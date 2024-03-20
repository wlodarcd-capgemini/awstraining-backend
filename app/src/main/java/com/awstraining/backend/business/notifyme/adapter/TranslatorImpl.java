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
    
    private AmazonTranslate translate;

    @Autowired
    public TranslatorImpl(AmazonTranslate translate) {
        this.translate = translate;
    }
    
    @Override
    public String translate(NotifyMeDO notifyMeDO) {
        final TranslateTextRequest translateRequest = new TranslateTextRequest()
                .withText(notifyMeDO.text())
                .withSourceLanguageCode(notifyMeDO.sourceLc())
                .withTargetLanguageCode(notifyMeDO.targetLc());

        final TranslateTextResult translateResult = translate.translateText(translateRequest);
        
        LOGGER.info("Text '{}' was successful translated from {} to {} with result '{}'", 
                notifyMeDO.text(), notifyMeDO.sourceLc(), notifyMeDO.targetLc(), translateRequest.getText());
        
        return translateResult.getTranslatedText();
    }
}
