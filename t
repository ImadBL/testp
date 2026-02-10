https://docs.tibco.com/pub/amx-bpm/4.3.3/doc/html/BPM_Developers_Guide/soap-api-saveopenworkitem.htm

<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:api="http://api.brm.n2.tibco.com">
   <soapenv:Header/>
   <soapenv:Body>
      <api:saveOpenWorkItem>
         <workItemID id="4" version="9"/>
         <workItemPayload>
            <dataModel>
               <inputs array="false" name="ContactPhone" type="String">
                  <simpleSpec>
                     <value>778-677-7888</value>
                  </simpleSpec>
               </inputs>
               <inputs array="false" name="Message" type="String">
                  <simpleSpec>
                     <value>Wants to buy a model ZZ-900.</value>
                  </simpleSpec>
               </inputs>
               <inputs array="false" name="ContactName" type="String">
                  <simpleSpec>
                     <value>Frank Johnson</value>
                  </simpleSpec>
               </inputs>
               <inouts array="false" name="Notes" type="String">
                  <simpleSpec>
                     <value>Is not interested in the Classic model.</value>
                  </simpleSpec>
               </inouts>
            </dataModel>
         </workItemPayload>
      </api:saveOpenWorkItem>
   </soapenv:Body>
</soapenv:Envelope>
