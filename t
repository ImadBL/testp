npm install -g @openapitools/openapi-generator-cli

pip install openapi-generator-cli
openapi-generator-cli version


openapi-generator-cli generate \
  -i swagger.yaml \
  -g java \
  -o generated/java-client \
  --additional-properties=dateLibrary=java8



openapi-generator-cli generate \
  -i swagger.yaml \
  -g spring \
  -o generated/spring-server \
  --additional-properties=interfaceOnly=true,useSpringBoot3=true


openapi-generator-cli generate \
  -i swagger.yaml \
  -g java \
  -o generated/java-models \
  --global-property=models,apis= \
  --additional-properties=hideGenerationTimestamp=true
