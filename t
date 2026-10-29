----
import java.util.Map;

import org.springframework.context.annotation.Bean;
import org.springframework.http.converter.FormHttpMessageConverter;
import org.springframework.security.oauth2.client.ClientCredentialsOAuth2AuthorizedClientProvider;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.endpoint.OAuth2ClientCredentialsGrantRequest;
import org.springframework.security.oauth2.client.endpoint.RestClientClientCredentialsTokenResponseClient;
import org.springframework.security.oauth2.client.http.OAuth2ErrorResponseErrorHandler;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.oauth2.client.web.DefaultOAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.web.OAuth2AuthorizedClientRepository;
import org.springframework.security.oauth2.core.ClientAuthenticationMethod;
import org.springframework.security.oauth2.core.endpoint.OAuth2ParameterNames;
import org.springframework.security.oauth2.core.http.converter.OAuth2AccessTokenResponseHttpMessageConverter;
import org.springframework.web.client.RestClient;
import org.springframework.web.util.DefaultUriBuilderFactory;
import org.springframework.web.util.UriComponentsBuilder;

@Bean
public OAuth2AuthorizedClientManager authorizedClientManager(
        ClientRegistrationRepository gedClientRegistrationRepository,
        OAuth2AuthorizedClientRepository authorizedClientRepository) {

    // L'URL sera encodée explicitement lors de sa construction.
    var uriFactory = new DefaultUriBuilderFactory();
    uriFactory.setEncodingMode(DefaultUriBuilderFactory.EncodingMode.NONE);

    var restClient = RestClient.builder()
            .uriBuilderFactory(uriFactory)
            .messageConverters(converters -> {
                converters.clear();
                converters.add(new FormHttpMessageConverter());
                converters.add(new OAuth2AccessTokenResponseHttpMessageConverter());
            })
            .defaultStatusHandler(new OAuth2ErrorResponseErrorHandler())
            .build();

    var tokenResponseClient =
            new RestClientClientCredentialsTokenResponseClient();

    tokenResponseClient.setRestClient(restClient);

    // Les identifiants seront dans l'URL : on les retire du corps.
    tokenResponseClient.setParametersCustomizer(parameters -> {
        parameters.remove(OAuth2ParameterNames.CLIENT_ID);
        parameters.remove(OAuth2ParameterNames.CLIENT_SECRET);
    });

    var authorizedClientProvider =
            new ClientCredentialsOAuth2AuthorizedClientProvider();

    authorizedClientProvider.setAccessTokenResponseClient(grantRequest -> {
        var registration = grantRequest.getClientRegistration();

        String tokenUri = UriComponentsBuilder
                .fromUriString(registration.getProviderDetails().getTokenUri())
                .replaceQueryParam("client_id", "{clientId}")
                .replaceQueryParam("client_secret", "{clientSecret}")
                .encode()
                .buildAndExpand(Map.of(
                        "clientId", registration.getClientId(),
                        "clientSecret", registration.getClientSecret()))
                .toUriString();

        var apigeeRegistration = ClientRegistration
                .withClientRegistration(registration)
                .tokenUri(tokenUri)
                // Aucun header Basic : authentification via l'URL.
                .clientAuthenticationMethod(ClientAuthenticationMethod.NONE)
                .build();

        return tokenResponseClient.getTokenResponse(
                new OAuth2ClientCredentialsGrantRequest(apigeeRegistration));
    });

    var manager = new DefaultOAuth2AuthorizedClientManager(
            gedClientRegistrationRepository,
            authorizedClientRepository);

    manager.setAuthorizedClientProvider(authorizedClientProvider);

    return manager;
}
