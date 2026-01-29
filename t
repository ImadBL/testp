java -jar openapi-generator-cli-7.7.0.jar generate ^
  -i swagger.yaml ^
  -g java ^
  -o generated/java-models ^
  --global-property models ^
  --additional-properties=hideGenerationTimestamp=true,dateLibrary=java8
