openapi-config.json:
{
  "generatorName": "java",
  "library": "resttemplate",
  "outputDir": "generated/java-client",
  "apiPackage": "com.mycompany.ged.api",
  "modelPackage": "com.mycompany.ged.model",
  "invokerPackage": "com.mycompany.ged.invoker",
  "additionalProperties": {
    "dateLibrary": "java8",
    "hideGenerationTimestamp": "true",
    "generateClientAsBean": "true",
    "useLombokAnnotations": "true",
    "useJakartaEe": "false"
  }
}

java -jar openapi-generator-cli-7.7.0.jar generate \
  -i swagger.yaml \
  -c openapi-config.json


