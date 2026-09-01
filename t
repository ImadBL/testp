<plugin>
    <groupId>org.jvnet.jaxb</groupId>
    <artifactId>jaxb-maven-plugin</artifactId>
    <version>4.0.8</version>

    <executions>
        <execution>
            <goals>
                <goal>generate</goal>
            </goals>
        </execution>
    </executions>

    <configuration>
        <schemaDirectory>
            src/main/resources/xsd/
        </schemaDirectory>

        <generatePackage>
            xxx.generated
        </generatePackage>
    </configuration>
</plugin>
